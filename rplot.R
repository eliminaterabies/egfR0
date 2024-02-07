library(dplyr)
library(ggplot2); theme_set(theme_bw())

library(shellpipes)
startGraphics()

## FIXME; what is a good way to order these factors?
dat <- (rdsRead()
	## |> mutate(loc = factor(loc, levels=rev(levels(loc))))
)

print(ggplot(dat)
	+ aes(x=loc, y=r_est, color=phase)
	+ geom_pointrange(aes(ymin=lwr,ymax=upr)
		, position = position_dodge(width=-0.4)
	)
	+ coord_flip()
	+ ylab("r (1/month)")
)

