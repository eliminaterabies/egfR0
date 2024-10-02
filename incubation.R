## Creating bites and incubation (by dog type.. biter, non-biter, biter_rep)  dataframe 

library(dplyr)
library(ggplot2);theme_set(theme_bw())
library(shellpipes)

intervals <- rdsRead()
## Do we need the high cap to get decent plots?

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
	%>% filter(!is.na(ID))
	%>% distinct()
	%>% left_join(bites)
	%>% distinct()
)

## manually repeating multiple bites
biters_rep_incubation <- rep(biters[["dateinc"]], biters[["count"]])


## non-biter incubation
non_biter_incubation <- (intervals
	%>% filter(!is.na(ID))
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

## we first combine biters and non-biter incubation period and the type will be Dogs. We then combine with the different categories of dogs and calculate the mean and sd.
incubations <- (biters_incubation
	%>% bind_rows(.,non_biter_incubation)
	%>% mutate(Type = "Dogs")
	%>% bind_rows(.,biters_incubation, non_biter_incubation, biters_incubation_rep
	)
	%>% mutate(Type = factor(Type, levels=c("Biter", "Biter_rep", "Non-Biter", "Dogs"))
	)
	%>% ungroup()
	%>% mutate(Type = as.character(Type))
)

print(incubations)

saveVars(bites,incubations)
