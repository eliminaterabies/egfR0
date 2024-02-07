library(dplyr)
library(ggplot2); theme_set(theme_bw())

library(shellpipes)
startGraphics()

## FIXME: what is a good way to order these factors?
## HINT: Do _not_ take the line below as a starting point; try the forcats package instead.
## We should figure out how to make them appear forward alphabetically, but also how to order them by the mean value of r.
dat <- (rdsRead()
	## |> mutate(loc = factor(loc, levels=rev(levels(loc))))
)

print(ggplot(dat)
	+ aes(x=loc, y=est, color=phase)
	+ geom_pointrange(aes(ymin=lwr,ymax=upr)
		, position = position_dodge(width=-0.4)
	)
	+ coord_flip()
	+ ylab("r (1/month)")
)

