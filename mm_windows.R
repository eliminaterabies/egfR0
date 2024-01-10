library(tidyverse)

library(shellpipes)

## Get both minPeak and long 
loadEnvironments()

findWin <- function(t, c, mp, ml, mc){
	if(max(c) < mp) return(data.frame(offset=NULL, cases=NULL))
	ind <- 1:(2+length(c))
	c <- c(0, c, NaN)
	t <- c(0, t, NaN)
	
	## from one past lastPreZero to one past the global peak
	## FIXME: It would be nice to allow a flexible number of zero/NAs before breaking, but not super-straightforward
	maxInd <- which.max(c)
	lastPreZero <- max(which(c==0 & ind<maxInd))
	if(maxInd+1<length(c)){maxInd <- maxInd+1}
	range <- (1+lastPreZero):maxInd
	if(length(range)<ml) return(data.frame(offset=NULL, cases=NULL))

	rf <- data.frame(offset=t[range], cases=c[range])

	## Check minimum climb criterion
	smin <- pmax(1, min(rf$cases))
	smax <- max(rf$cases)
	if (smax<smin*mc) return(data.frame(month=NULL, cases=NULL))

	return(rf)
}

selected <- (long
	%>% group_by(loc, phase)
	%>% reframe(findWin(offset, cases, minPeak, minLength, minClimb))
)

windows <- (selected
	|> select(loc, phase)
	|> distinct()
	|> mutate(start=-Inf, end=Inf)
)

summary(selected)

saveVars(long, selected, windows)
