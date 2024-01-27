library(tidyverse)
library(epigrowthfit)
library(shellpipes)

loadEnvironments()

nsamp <- 100

rsamps <- function(x,n=100){
	mm <-coef(x)[1]
	vv <- diag(vcov(x))[1]
	exp(rnorm(n=n,mean=mm,sd=sqrt(vv)))
}


egf_df <- (rdsRead()
#	%>% group_by(loc,phase,egf_fit)
	%>% mutate(rsamp = map(egf_fit,~rsamps(.,n=nsamp))) 
)
 
rdsSave(egf_df)



