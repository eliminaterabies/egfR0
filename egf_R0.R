library(tidyverse)
library(epigrowthfit)
library(shellpipes)

loadEnvironments()

gi <- (interval_df
	%>% filter(Type == "Generation")
	%>% pull(Days)
)

nboot <- 100
nsamp <- 300


egf_df <- (rdsRead()
#	%>% group_by(loc,phase,egf_fit)
	%>% mutate(R0sims = map(rsamp,~simR0_data(.,time=gi,n=nsamp,bootsample=nboot)))
)

print(egf_df)

rdsSave(egf_df)






