library(tidyverse)
library(epigrowthfit)
library(shellpipes)

loadEnvironments()

fakewin <- data.frame(start = -Inf, end=Inf)

print(windows)

egffun <- function(x){
	mod <- egf(model = egf_model(curve = "logistic", family = "nbinom")
		, data_ts = x
		, formula_ts = cbind(offset, cases) ~ 1
		, formula_parameters = ~ 1
		, data_windows = fakewin
		, formula_windows = cbind(start, end) ~ 1
		, se = TRUE
	) 
	return(mod)
}     

## Needs to be simplified (three functions to one)
rlwr <- function(x){
	cf <- confint(x[[1]],probs=c(0.025,0.975))
	return(exp(cf[["lower"]][1]))
}

rupr <- function(x){
	cf <- confint(x[[1]],probs=c(0.025,0.975))
	return(exp(cf[["upper"]][1]))
}

r_est <- function(x){
	return(exp(coef(x[[1]])[[1]]))
}

r_ests <- function(x){
	cf <- confint(x[[1]],probs=c(0.025,0.975))
	df <- data.frame(lwr=exp(cf[["lower"]][[1]])
		, est = exp(cf[["estimate"]][[1]])
		, upr = exp(cf[["upper"]][[1]])
	)
	return(df)
}


## Do we need map here? Why??
ff <- (selected
	%>% group_by(loc,phase)
	%>% nest()
	%>% mutate(egf_fit = map(data,~ egffun(.)))
)

print(ff)

print(ff$egf_fit)

fulldat <-(ff
#	%>% mutate(r_est = r_est(egf_fit)
#		, lwr = rlwr(egf_fit)
#		, upr = rupr(egf_fit)
#	)
	%>% reframe(r_ests(egf_fit))
)

print(fulldat)

rdsSave(fulldat)

