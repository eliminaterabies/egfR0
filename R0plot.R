library(dplyr)
library(ggplot2); theme_set(theme_bw())

library(shellpipes)
startGraphics()

## Doing vaccination correction here
dat <- (rdsRead()
	|> left_join(tsvRead(),by=c("loc"="varname"))
	|> mutate(NULL
	, est = est/(1-vac)
	, lwr = lwr/(1-vac)
	, upr = upr/(1-vac)
	, loc = forcats::fct_reorder(loc,est,.fun = mean, .na_rm=FALSE))
)

print(dat)

gg <- (ggplot(dat, aes(x=loc))
	+ geom_pointrange(aes(ymin=lwr, y = est, ymax=upr, color=phase,lty=method)
		, position = position_dodge(width=-0.4)
	)
	+ scale_linetype_manual(values=c("dotted","solid"))
	+ scale_color_manual(values=c("black","red", "orange"))
	+ labs(y = "R0", x = NULL)
)

print(gg + coord_flip())

print(gg + coord_cartesian(ylim=c(0,3)) + coord_flip(ylim=c(0,3)))


rdsSave(gg)
