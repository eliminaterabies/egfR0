library(shellpipes)
manageConflicts()

library(tidyverse)

## Consider checking column types if there is a big upstream change
## There is a known problem in column 65, we're not using it.
animal <- csvRead(comment="#", show_col_types=FALSE, col_select = -65)

## number of cases (Serengeti dog cases)
print(dim(animal))

## Number of transmission events

dogsTransmissionNum <- nrow(animal)

## Check out Suspect column
print(summary(factor(animal[["Suspect"]])))

## number of cases with unknown biter
print(dim(animal %>% filter(Biter.ID == 0)))

## Number of distinct biters
print(dim(animal %>% filter(Biter.ID != 0) %>% select(Biter.ID) %>% distinct()))

## Number of suspected cases 
print(SuspectDogs <- (animal 
	%>% filter(Suspect %in% c("Yes","To Do", "Unknown"))
	)
)

dogsSuspectedNum <- nrow(SuspectDogs %>% select(ID) %>% distinct())

## Dogs with unknown biters

dogsUnknownBiter <- (SuspectDogs
	%>% filter(Biter.ID == 0)
)

unknownBiters <- nrow(dogsUnknownBiter)

## All animals should be Serengeti hear for now
table(animal$District)

bitten <- (animal
	%>% select(ID, Biter.ID , Suspect
		, Symptoms.started, Symptoms.started.accuracy
		, Date.bitten, Date.bitten.uncertainty
		, Outcome, Action
	)
	|> mutate(
		Suspect = factor(Suspect)
		, ID = factor(ifelse(ID==0, NA, ID))
		, Biter.ID = factor(ifelse(Biter.ID==0, NA, Biter.ID))
	)
)

## Total bites recorded (not necessarily all from dogs)
biteCount <- (bitten
   ## %>% filter(Suspect %in% c("Yes", "To Do", "Unknown"))
	## Purpose unknown 2024 Apr 20 (Sat)
	## We should need bitees to be rabid
   %>% group_by(ID)
   %>% summarize(timesBitten=n())
   %>% ungroup()
)

## Number of multiple exposures
print(biteCount %>% filter(timesBitten>1), n=50)

bitten <- full_join(bitten, biteCount)
saveVars(dogsTransmissionNum, dogsSuspectedNum, unknownBiters)
rdsSave(bitten)
