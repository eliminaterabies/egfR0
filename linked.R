# Link focal dog's biter

library(dplyr)
library(shellpipes)

## bitten 

bitten <- rdsRead()

biters <- (bitten 
	%>% select(-Biter.ID)
)

print(dim(biters))
print(dim(biters %>% filter(Suspect == "Yes")))


biterCount <- (bitten
#	%>% filter(Suspect %in% c("Yes", "To Do", "Unknown"))
	%>% filter(!is.na(Biter.ID) & (Biter.ID > 0))
	%>% group_by(Biter.ID)
	%>% summarize(secondaryInf=n())
	%>% arrange(desc(secondaryInf))
	%>% select(ID=Biter.ID, secondaryInf)
)

print(biterCount)

## number of biters
print(nrow(biterCount))

links <- (bitten
	%>% filter(Suspect %in% c("Yes","To Do", "Unknown"))
	%>% left_join(., biters
	, by=c("Biter.ID"="ID", "District"="District")
	, suffix=c("", ".biter")
	)
	%>% left_join(.,biterCount)
)


print(weird_links <- links 
	%>% select(Suspect.biter, Biter.ID, ID, Suspect, everything(.))
	%>% filter(Suspect.biter %in% c("No", "Impossible"))
	%>% mutate(R0_note = "weird links")
)

print(links %>% filter(timesBitten > 1))

print(nrow(links))

## Not sure why we need this calculation
print(nrow(links) - nrow(biterCount))


print(checks <- links 
	%>% select(Biter.ID, Suspect.biter, ID, Suspect)
	%>% filter(Biter.ID > 0)	
	%>% filter(Suspect.biter %in% c("No","Impossible"))
	%>% filter(Suspect == "Yes")
	, n=100
)

saveVars(links, weird_links)

