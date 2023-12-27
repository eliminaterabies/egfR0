## Checking code

library(tidyverse)

library(shellpipes)

## Please use Serengeti_dogs_incubation.csv in rabies_db_pipeline/output and rename it to dogs.csv in this repo
## If you are using make, this might already be a link
## This is a consense dataset that is only looking at Serengeti dogs with bestInc (incubation period via date or reported if date is not avaliable)

dogs <- csvRead()

dogsTransmissionNum <- nrow(dogs)

## number of transmission events (i.e., domestic dog bitten by an animal)
print(dogsTransmissionNum <- nrow(dogs))

## number of suspected dogs

SuspectDogs <- (dogs
	%>% filter(Suspect %in% c("Yes","To Do", "Unknown"))
	%>% select(ID, Suspect, Biter.ID, Symptoms.started, Date.bitten, bestInc)
)


dogsSuspectedNum <- (nrow(SuspectDogs
	%>% select(ID)
	%>% distinct() ## removing repeating ID (i.e, dogs with bitten more than once)
))

print(dogsSuspectedNum)

## dogs with unknown biters

dogsUnknownBiter <- (SuspectDogs
	%>% filter(Biter.ID == 0)
)

print(nrow(dogsUnknownBiter))

## We really have about 
print(dogsSuspectedNum - nrow(dogsUnknownBiter))
## cases that can be linked (i.e., this is the number of dogs that have a "known" biter)


## make sure we are getting the "correct" linkage
## We want biter and bitee to be bitten once

bitten <- (dogs
   %>% select(ID, Biter.ID, Suspect
      , Symptoms.started, Symptoms.started.accuracy
      , Date.bitten, Date.bitten.uncertainty
      , Incubation.period, Incubation.period.units
      , Infectious.period, Infectious.period.units
      , Outcome, Action, everything()
   )
   ## Process units (function from Mike)
   ## Keep the unit in days as a measure of uncertainty
)

## Note, probably not even bitten by dogs..
timesBitten <- (bitten
   %>% filter(Suspect %in% c("Yes", "To Do", "Unknown"))
   %>% ungroup()
   %>% group_by(ID)
   %>% summarize(timesBitten=n())
)

## Number of multiple exposures
print(timesBitten %>% filter(timesBitten>1), n=50)

bitten <- (full_join(bitten, timesBitten)
   %>% filter(Suspect %in% c("Yes", "To Do", "Unknown"))
)

## biter facts

biters <- (bitten 
        %>% select(-Biter.ID)
)

print(dim(biters))
print(dim(biters %>% filter(Suspect == "Yes")))


biterCount <- (bitten
       %>% filter(Suspect %in% c("Yes", "To Do", "Unknown"))
        %>% filter(!is.na(Biter.ID) & (Biter.ID > 0))
        %>% group_by(Biter.ID)
        %>% summarize(secondaryInf=n())
        %>% arrange(desc(secondaryInf))
        %>% select(ID=Biter.ID, secondaryInf)
)

print(biterCount)
biterCount <- biterCount %>% filter(secondaryInf>0)
print(sum(biterCount$secondaryInf))
print(mean_biting_freq <- mean(biterCount$secondaryInf))


## Linking biters info to bitten dataset

links <- (left_join(bitten, biters
	, by = c("Biter.ID"="ID") ## c(A,B) means linking A in SuspectDogs with B in biters dataset... we are doing this so we can get "biter" info
	, suffix=c("",".biter")
	)
	  %>% left_join(.,biterCount)
)

## calculating intervals 

intervals <- (links
	%>% rowwise()
	%>% mutate(dateInc=as.numeric(Symptoms.started - Date.bitten)
	, dateIncBiter = as.numeric(Symptoms.started.biter - Date.bitten.biter)
	, dateSerial=as.numeric(Symptoms.started - Symptoms.started.biter)
	, dateGen=as.numeric(Date.bitten - Date.bitten.biter)
	)
)

print(problematic_mexposures <- intervals
	%>% filter(timesBitten > 1)
	%>% select(ID, dateGen, Date.bitten, Date.bitten.biter)
	%>% group_by(ID)
	%>% filter(!is.na(sum(dateGen)))
)

## Getting rid of multiple exposures

intervals <- (intervals
	%>% filter(!(ID %in% problematic_mexposures[["ID"]]))
)


## only filtering dogs that are bitten once
intervals <- (intervals
   %>% ungroup()
   %>% filter(
      timesBitten==1
      & (timesBitten.biter==1 | is.na(timesBitten.biter))
   )
)

print(summary(factor(intervals[["Suspect.biter"]])))

intervals <- (intervals
   %>% filter(Suspect %in% c("Yes","To Do", "Unknown"))
   %>% filter(Suspect.biter %in% c("Yes","To Do", "Unknown"))
   %>% filter(!(ID %in% c(161, 628, 7966, 7967))) ## temp removing problematic    multiple exposures
)


## Incubation periods


maxDays <- 1000
minDays <- 0

## biter incubation with repeats
biters_rep <- (intervals
	%>% filter(!is.na(dateIncBiter))
	%>% filter(between(dateIncBiter, minDays, maxDays))
	%>% select(ID = Biter.ID
		, dateinc = dateIncBiter
		)
)

## count number of bites
bites <- (biters_rep
	%>% group_by(ID)
	%>% summarise(count = n())
)


## combine biter incubation and number of bites
biters <- (biters_rep
	%>% filter(ID>0)
	%>% distinct()
	%>% left_join(bites)
	%>% distinct()
)

## manually repeating multiple bites
biters_rep_incubation <- rep(biters[["dateinc"]], biters[["count"]])


## non-biter incubation
non_biter_incubation <- (intervals
	%>% filter(ID>0)
	%>% filter(District == "Serengeti")
	%>% filter(!(ID %in% biters$ID))
	%>% filter(between(dateInc, minDays, maxDays))
	%>% select(ID, dateInc)
	%>% distinct()
)

## manually combining incubation dataframe
biters_incubation_rep <- (data.frame(Type = "Biter_rep"
	, Days = biters_rep_incubation)
)

print(summary(biters_incubation_rep))

biters_incubation <- (biters
	%>% transmute(Type = "Biter"
		, Days = dateinc)
)


print(summary(biters_incubation))

non_biter_incubation <- (non_biter_incubation
	%>% transmute(Type = "Non-Biter"
		, Days = dateInc
		)
)

incubations <- (biters_incubation
	%>% bind_rows(.,non_biter_incubation)
	%>% mutate(Type = "Dogs")
	%>% bind_rows(.,biters_incubation, non_biter_incubation, biters_incubation_rep
	)
	%>% mutate(Type = factor(Type, levels=c("Biter", "Biter_rep", "Non-Biter", "Dogs"))
	)
	%>% group_by(Type)
	%>% mutate(Mean = mean(Days)
		, SD = sd(Days)
		)
	%>% ungroup()
	%>% mutate(Type = as.character(Type))
)

print(incubations)

## Calculating serial and generation interval moments 


tidyInts <- (intervals
	%>% select(dateSerial
		, dateGen
		)
	%>% gather(key=Type,value=Days, everything())
	%>% filter(between(Days, minDays, maxDays)) ## experimenting removing outliers
)


print(dim(tidyInts))
## taking out wait time
#wait_times <- tidyInts %>% filter(Type == "wait_time")


interval_df <- (tidyInts
	%>% transmute(Type = ifelse(grepl("Serial",Type),"Serial","Generation")
      	, Days
		)
	%>% group_by(Type)
	%>% mutate(Mean = mean(Days, na.rm=TRUE)
		)
)



interval_merge <- (interval_df
	%>% bind_rows(.,incubations)
	%>% ungroup()
	%>% mutate(Type = factor(Type, levels=c("Serial","Generation"
		, "Dogs", "Biter_rep", "Non-Biter", "Biter")
		, labels=c("Serial Interval", "Generation Interval"
			, "Incubation Period: Dogs"
			, "Weighted Incubation Period"
			, "Incubation Period: Non-Biter"
			, "Incubation Period: Biter"
			)
		)
		)
)

print(timesummary <- interval_merge 
	%>% group_by(Type) 
	%>% summarise(count = n()) 
	%>% left_join(.,interval_merge)
	%>% select(Type, count, Mean)
	%>% distinct()
)

meanVec <- setNames(timesummary[["Mean"]],timesummary[["Type"]])
countVec <- setNames(timesummary[["count"]],timesummary[["Type"]])

print(meanVec)
print(countVec)

## We are only keeping these two times for the paper to call on
saveVars(dogsTransmissionNum,dogsSuspectedNum, dogsUnknownBiter,meanVec,countVec, mean_biting_freq)
