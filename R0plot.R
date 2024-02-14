library(dplyr)
library(ggplot2); theme_set(theme_bw())

library(shellpipes)
startGraphics()


dat <- (rdsRead()
	## |> mutate(loc = factor(loc, levels=rev(levels(loc))))
	## %>% filter(phase != 3) ## removing toyko phase 3s
)

print(dat)

gg <- (ggplot(dat
	, aes( x = forcats::fct_reorder(loc, est, .fun = mean, .na_rm = FALSE)
	        )
)
	+ geom_pointrange(aes(ymin=lwr
	                      , y = est
	                      , ymax=upr
	                      , color=phase)
		, position = position_dodge(width=-0.4)
	)
	+ scale_color_manual(values=c("black","red", "orange"))
	+ labs(y = "R0", x = NULL)
)

print(gg + coord_flip())

print(gg + coord_cartesian(ylim=c(0,3)) + coord_flip(ylim=c(0,3)))


rdsSave(gg)
