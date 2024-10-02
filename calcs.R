# Calculating different intervals

library(dplyr)
library(tidyr)
library(ggplot2)
library(shellpipes)

commandEnvironments()

intervals <- (rdsRead()
	%>% rowwise()
	%>% mutate(
		dateInc=as.numeric(Symptoms.started - Date.bitten) 
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

intervals <- (intervals 
	%>% filter(!(ID %in% problematic_mexposures[["ID"]]))
)

print(intervals)

print(badGen <- intervals 
	%>% filter((dateGen < 0)|(dateGen > 150)) 
	%>% select(ID,dateGen,everything(.))
	%>% mutate(R0_note = "Bad dateGen")
)

saveVars(intervals, badGen)
