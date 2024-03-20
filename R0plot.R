library(dplyr)
library(ggplot2); theme_set(theme_bw())

library(shellpipes)
startGraphics()

loadEnvironments()

## Doing vaccination correction here
dat <- (egf_gi2
	|> left_join(tsvRead(),by=c("loc"="varname"))
	|> mutate(NULL
	, est = est/(1-vac)
	, lwr = lwr/(1-vac)
	, upr = upr/(1-vac)
	, loc_final = ifelse(loc == "Tokyo1", "Tokyo",loc)
	, loc_final = ifelse(loc_final == "Tokyo2", "Tokyo",loc_final)
	, loc_final = paste0(loc_final, "\n", year)
	, loc_final = forcats::fct_reorder(loc_final,est,.fun = mean, .na_rm=FALSE))
)

print(dat)

gg <- (ggplot(filter(dat,method=="Logistic"), aes(x=loc_final))
	+ geom_pointrange(aes(ymin=lwr, y = est, ymax=upr, color=phase)
		, position = position_dodge(width=-0.4)
	)
#	+ scale_linetype_manual(values=c("dotted","solid"))
	+ scale_color_manual(values=c("black","red", "orange"))
	+ labs(y = "R0", x = NULL)
)

print(gg + coord_flip())

print(gg + coord_cartesian(ylim=c(0,3)) + coord_flip(ylim=c(0,3)))


rdsSave(gg)
