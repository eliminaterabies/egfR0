library(tidyverse)
library(epigrowthfit)
library(shellpipes)

loadEnvironments()

print(interval_df)

si <- (interval_df
	%>% filter(Type == "Serial")
	%>% pull(Days)
)

gi <- (interval_df
	%>% filter(Type == "Generation")
	%>% pull(Days)
)

nboot <- 100
nsamp <- 300


egf_gi <- (bind_rows(rdsReadList())
#	%>% group_by(loc,phase,egf_fit)
	%>% mutate(R0sims = map(rsamp,~simR0_data(.,time=gi,n=nsamp,bootsample=nboot)))
	%>% group_by(loc,phase,method)
	%>% reframe(R0tiles(R0sims))
	%>% mutate(interval = "Generation")
)


egf_si <- (bind_rows(rdsReadList())
#	%>% group_by(loc,phase,egf_fit)
	%>% mutate(R0sims = map(rsamp,~simR0_data(.,time=si,n=nsamp,bootsample=nboot)))
	%>% group_by(loc,phase,method)
	%>% reframe(R0tiles(R0sims))
	%>% mutate(interval = "Serial")
)


saveVars(egf_gi,egf_si)

