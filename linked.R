# Link focal dog's biter

library(dplyr)
library(shellpipes)

bitten <- rdsRead()

## bitten 

biters <- (bitten 
	%>% select(-Biter.ID)
	%>% filter(Suspect %in% c("Yes","To Do", "Unknown"))
)
print(dim(biters))

biterCount <- (bitten
	%>% filter(!is.na(Biter.ID))
	%>% group_by(Biter.ID)
	%>% summarize(secondaryInf=n())
	%>% arrange(desc(secondaryInf))
	%>% select(ID=Biter.ID, secondaryInf)
)

print(biterCount)

## number of biters
print(nrow(biterCount))

links <- (bitten
	%>% left_join(., biters
		, by=c("Biter.ID"="ID")
		, suffix=c("", ".biter")
		, relationship = "many-to-many"
	)
	%>% left_join(.,biterCount, by="ID")
)

print(links %>% filter(timesBitten > 1))

print(nrow(links))

## Not sure why we need this calculation
print(nrow(links) - nrow(biterCount))
summary(biterCount)
print(mean_biting_freq <- mean(biterCount$secondaryInf))

## Secret data in .rds; public in .rda
rdsSave(links)
saveVars(mean_biting_freq)

