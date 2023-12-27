library(tidyverse)
library(epigrowthfit)
library(shellpipes)

loadEnvironments()

keep <- c("Israel", "Java", "Mexico", "Ngorongoro")

df <- (filter(selected, loc %in% keep) 
	%>% mutate(loc = factor(loc))
	%>% arrange(loc,offset)
)

em <- egf(model = egf_model(curve = "logistic", family = "nbinom"),
	data_ts = df,
	formula_ts = cbind(offset, cases) ~ loc,
	formula_parameters = ~ loc,
	data_windows = windows,
	formula_windows = cbind(start, end) ~ loc,
	se = TRUE
)

print(em)

print(coef(em))

print(confint(em))

