library(dplyr, warn.conflicts=FALSE)
library(ggplot2); theme_set(theme_bw())
library(forcats)
library(shellpipes)

startGraphics()


dat <- (bind_rows(rdsRead("exp"),rdsRead("logistic"))
	## |> mutate(loc = factor(loc, levels=rev(levels(loc))))
)

print(
       ggplot(dat)
	+ aes(
	    # to simply reverse:
	    # x=forcats::fct_rev(loc)
	    # This is reordering by the first est for each loc:
	    # x = forcats::fct_reorder(loc, est)
	    # This is reordering by the mean est:
	    x = forcats::fct_reorder(loc, est, .fun = mean)
	    , y=est, color=phase)
	+ geom_pointrange(aes(ymin=lwr,ymax=upr,lty=method)
		, position = position_dodge(width=-0.4)
	)
	+ coord_flip()
	# note that x and y are switched!
	+ labs(y = "r (1/month)", x = NULL)
)

