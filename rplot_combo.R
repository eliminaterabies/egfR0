library(dplyr, warn.conflicts=FALSE)
library(ggplot2); theme_set(theme_bw())
library(forcats)
library(shellpipes)

startGraphics()

dat <- (bind_rows(rdsReadList())
	|> left_join(tsvRead(),by=c("loc"="varname"))
	%>% mutate(loc_final = ifelse(loc == "Tokyo1", "Tokyo",loc)
		, loc_final = ifelse(loc_final == "Tokyo2", "Tokyo",loc_final)
   	, loc_final = paste0(loc_final, "\n", year)
	)

#	rbind(readRDS("exp.egf_single.rds"),readRDS("logistic.egf_single.rds"))
	## |> mutate(loc = factor(loc, levels=rev(levels(loc))))
)


print(dat)

print(
       ggplot(dat)
	+ aes(
	    # to simply reverse:
	    # x=forcats::fct_rev(loc)
	    # This is reordering by the first est for each loc:
	    # x = forcats::fct_reorder(loc, est)
	    # This is reordering by the mean est:
	    x = forcats::fct_reorder(loc_final, est, .fun = mean)
	    , color=phase)
	+ geom_pointrange(aes(y=est,ymin=lwr,ymax=upr,lty=method)
		, position = position_dodge(width=-0.4)
	)
#	+ geom_point(aes(y=est),position = position_dodge(width=-0.4))
#	+ geom_segment(aes(xend=forcats::fct_reorder(loc_final,est,.fun=mean),lty=method,y=lwr,yend=upr),position=position_dodge(width=-0.4))
	+ scale_linetype_manual(values=c("dotted","solid"))
	+ scale_color_manual(values=c("black","red", "orange"))
	+ coord_flip()
	# note that x and y are switched!
	+ labs(y = "r (1/month)", x = NULL)
)

