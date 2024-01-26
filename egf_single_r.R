library(tidyverse)
library(epigrowthfit)
library(shellpipes)

egf_fit_dat <- rdsRead()

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

fulldat <-(egf_fit_dat
	%>% mutate(r_est = r_est(egf_fit)
		, lwr = rlwr(egf_fit)
		, upr = rupr(egf_fit)
	)
)

print(fulldat)

rdsSave(fulldat)


