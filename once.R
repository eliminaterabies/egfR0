library(dplyr)
library(shellpipes)

loadEnvironments()

print(intervals)

## only filtering dogs that are bitten once
# print(head(intervals))

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
	%>% filter(!(ID %in% c(161, 628, 7966, 7967))) ## temp removing problematic multiple exposures
)

print(summary(intervals %>% select(dateGen)))
print(table(intervals %>% select(dateGen) %>% filter(!is.na(dateGen))))

rdsSave(intervals)
