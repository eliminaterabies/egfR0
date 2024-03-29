library(tidyverse);theme_set(theme_bw())
library(shellpipes); startGraphics(width=10)

el <- loadEnvironmentList(trim="\\..*$")
el
objects(el[[1]])
quit()

combodat <- (bind_rows(softClimb,lowPeaks,softDecline,base)
	|> mutate(parlist = paste0(parset," ",parlist))
)

comboSelected <- bind_rows(softClimb_points, lowPeaks_points,softDecline_points,base_points)

print(combodat)

palette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

combodat |> pull(loc) |> unique() |> walk(function(x){
	print(ggplot(combodat |> filter(loc==x))
		+ aes(x=offset, y=cases)
		+ geom_line()
		+ geom_line(aes(color=phase))
		+ facet_wrap(~parlist,nrow=2)
		+ ggtitle(x)
		+ geom_point(dat=comboSelected |> filter(loc==x), aes(color=phase), size=4)
 		+ scale_colour_manual(values=palette)
		+ xlab("offset (months)")
		+ theme(strip.text = element_text(size = 8))
	)
})




