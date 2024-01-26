library(tidyverse)
library(epigrowthfit)
library(shellpipes)

loadEnvironments()

fakewin <- data.frame(start = -Inf, end=Inf)

print(windows)

egfing <- function(x){
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


ff <- (selected
	%>% group_by(loc,phase)
	%>% nest()
	%>% mutate(egf_fit = map(data,~ egfing(.)))
)


print(ff)

print(ff$egf_fit)

rdsSave(ff)

