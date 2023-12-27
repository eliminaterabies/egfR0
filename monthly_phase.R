
library(tidyverse)

library(shellpipes)

minPeak <- 12
ratThresh <- 0.25

calcPhase <- function(v, mp, rt){
	T <- length(v)
	phase <- numeric(T)
	peak <- 0
	currPhase <- 1
	
	for (i in 1:T){
		if(v[[i]] > pmax(peak, mp)) peak <- v[[i]]
		if(v[[i]] < rt*peak){
			currPhase <- currPhase+1
			peak <- 0
		}
		phase[[i]] <- currPhase
	}
	return(as.character(phase))
}

long <- (rdsRead()
	%>% group_by(loc)
	%>% mutate(phase = calcPhase(cases, minPeak, ratThresh))
	%>% ungroup
)

summary(long)

saveVars(long, minPeak)

