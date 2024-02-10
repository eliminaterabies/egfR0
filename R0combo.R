library(ggplot2);theme_set(theme_bw())
library(shellpipes)

gg <- rdsRead("plot")
hampson <- rdsRead("KH")


print(gg 
	+ geom_linerange(data=hampson,aes(ymin=lower,ymax=upper),color="blue",size=3,alpha=0.2)
	+ coord_flip())

rdsSave(gg)

