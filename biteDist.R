library(shellpipes)
manageConflicts()

library(dplyr)

set.seed(100)

minDays <- 0
maxDays <- 100

bites <- (rdsRead()
	%>% select(Biter.ID,dateGen)
	%>% filter(between(dateGen,minDays,maxDays))
	%>% group_by(Biter.ID)
	%>% mutate(count=n())
	%>% ungroup()
)

idlist <- as.factor(sample(unique(bites[["Biter.ID"]])))

atab <- tibble(
	Biter.ID = idlist
	, anon = 1:length(idlist)
)

bites <- (left_join(bites, atab, by="Biter.ID")
	|> select(-Biter.ID)
)

print(bites, n=Inf)
summary(bites)

rdsSave(bites)
