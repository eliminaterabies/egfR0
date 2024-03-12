library(shellpipes)
sourceFiles()

library(tidyverse)

## Consider checking column types if there is a big upstream change
animal <- csvRead(comment="#", show_col_types=FALSE)
problems()

animal[65]

quit()

## number of cases (Serengeti dog cases)
print(dim(animal))

print(summary(factor(animal[["Suspect"]])))

## number of cases with unknown biter
print(dim(animal %>% filter(Biter.ID == 0)))

## Number of distinct biters
print(dim(animal %>% filter(Biter.ID != 0) %>% select(Biter.ID) %>% distinct()))

## Number of suspected cases 
print(dim(animal %>% filter(Suspect %in% c("Yes","To Do", "Unknown")))
)

bitten <- (animal
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
)

rdsSave(bitten)
