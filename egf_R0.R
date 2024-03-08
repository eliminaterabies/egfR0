library(tidyverse)
library(epigrowthfit)
library(shellpipes)

loadEnvironments()

minDays <- 0
maxDays <- 100

nboot <- 100
nsamp <- 100
print(interval_df)

## from once.rda

once <- (rdsRead("once")
	%>% select(Biter.ID,dateGen)
	%>% filter(between(dateGen,minDays,maxDays))
	%>% group_by(Biter.ID)
	%>% mutate(count=n())
	%>% arrange(Biter.ID)
)

simgencluster <- sim_clustertime(once,num=nboot,bootsample=nsamp)

print(simgencluster)

si <- (interval_df
	%>% filter(Type == "Serial")
	%>% pull(Days)
)

gi <- (interval_df
	%>% filter(Type == "Generation")
	%>% pull(Days)
)

egf_fit_dfs <- bind_rows(rdsRead("exp"),rdsRead("logistic"))

egf_gi <- (egf_fit_dfs
#	%>% group_by(loc,phase,egf_fit)
	%>% mutate(R0sims = map(rsamp,~simR0_data(.,time=gi,n=nsamp,bootsample=nboot)))
	%>% group_by(loc,phase,method)
	%>% reframe(R0tiles(R0sims))
	%>% mutate(interval = "Generation")
)

egf_gi2 <- (egf_fit_dfs
	%>% mutate(R0sims = map(rsamp,~clustersimR0_data(.,time=once,n=nsamp,bootsample=nboot)))
	%>% group_by(loc,phase,method)
	%>% reframe(R0tiles(R0sims))
	%>% mutate(interval = "Cluster-Generation")
)

print(egf_gi2)

egf_si <- (bind_rows(rdsReadList())
#	%>% group_by(loc,phase,egf_fit)
	%>% mutate(R0sims = map(rsamp,~simR0_data(.,time=si,n=nsamp,bootsample=nboot)))
	%>% group_by(loc,phase,method)
	%>% reframe(R0tiles(R0sims))
	%>% mutate(interval = "Serial")
)


saveVars(egf_gi,egf_gi2,egf_si,nboot,nsamp)

