library(ggplot2);theme_set(theme_bw())
library(shellpipes)
library(dplyr)
startGraphics()

gg <- rdsRead("plot")
hampson <- rdsRead("KH")


print(gg 
	+ geom_linerange(data=hampson %>% mutate(est = med)
	                 , aes(ymin=lower
	                       , ymax=upper)
	                 , color="blue"
	                 , linewidth = 3
	                 , alpha=0.2)
	+ coord_flip())

rdsSave(gg)


