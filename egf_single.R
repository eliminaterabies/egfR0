library(tidyverse)
library(epigrowthfit)
library(shellpipes)

loadEnvironments()

single_phase <- (selected
	|> select(loc,phase)
	|> distinct()
	|> group_by(loc)
	|> summarise(count = n())
	|> filter(count == 1)
)

keep <- single_phase[["loc"]]

df <- (filter(selected, loc %in% keep) 
	%>% mutate(loc = factor(loc))
	%>% arrange(loc,offset)
)

## First fit egf

egfing <- function(x){
	dat <- df %>% filter(loc == x)
	wins <- windows %>% filter(loc == x)

	em <- egf(model = egf_model(curve = "logistic", family = "nbinom"),
		data_ts = dat,
		formula_ts = cbind(offset, cases) ~ 1,
		formula_parameters = ~ 1,
		data_windows = wins,
		formula_windows = cbind(start, end) ~ 1,
		se = TRUE
	)
}

## r0 samples

rsamps <- function(x,n=100){
	mm <-coef(x)[1]
	vv <- diag(vcov(x))[1]
	exp(rnorm(n=n,mean=mm,sd=sqrt(vv)))
}


rsamples <- sapply(keep,function(x)rsamps(egfing(x)))

## Note, the units here is 1/month
print(rsamples)

print(summary(rsamples))
