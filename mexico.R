library(ggplot2);theme_set(theme_bw())
library(shellpipes)
library(dplyr)
startGraphics()

loadEnvironments()

mexico <- (bind_rows(egf_gi2,egf_si)
	%>% filter(loc == "Mexico")
	%>% transmute(method2 = paste0(method," \n + ",interval)
		, lwr
		, est
		, upr
	)
)

hampsondf <- (rdsRead()
	%>% filter(loc == "Mexico")
	%>% transmute(method2 = "Construction"
		, lwr = lower
		, est = med
		, upr = upper
	)
)

dat <- (bind_rows(mexico,hampsondf)
	%>% mutate(method2 = factor(method2
		, levels=c("Construction", "Exponential \n + Serial"
			, "Exponential \n + Generation"
			, "Logistic \n + Serial"
			, "Logistic \n + Generation"
			)
		)
	)
)

print(dat)

gg <- (ggplot(dat,aes(x=method2, y=est))
	+ geom_pointrange(aes(ymin=lwr,ymax=upr))
#	+ coord_flip()
)

print(gg)

