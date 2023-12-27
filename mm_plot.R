library(ggplot2); theme_set(theme_bw(base_size=14))
library(tidyverse)

library(shellpipes); startGraphics()
loadEnvironments()

long |> pull(loc) |> unique() |> walk(function(x){
	print(ggplot(long |> filter(loc==x))
		+ aes(x=offset, y=cases, color=phase)
		+ geom_line()
		+ ggtitle(x)
		+ geom_point(dat=selected |> filter(loc==x))
	)
})
