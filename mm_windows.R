library(tidyverse)

library(shellpipes)

## Get both minPeak and long 
loadEnvironments()
minLength <- 5

findWin <- function(t, c, mp, ml){
	if(max(c) < mp) return(data.frame(offset=NULL, cases=NULL))
	ind <- 1:(2+length(c))
	c <- c(0, c, NaN)
	t <- c(0, t, NaN)
	
	## from one past lastPreZero to one past the global peak
	maxInd <- which.max(c)
	lastPreZero <- max(which(c==0 & ind<maxInd))
	if(maxInd+1<length(c)){maxInd <- maxInd+1}
	range <- (1+lastPreZero):maxInd
	if(length(range)<ml) return(data.frame(offset=NULL, cases=NULL))

	return(data.frame(offset=t[range], cases=c[range]))
}

selected <- (long
	%>% group_by(loc, phase)
	%>% reframe(findWin(offset, cases, minPeak, minLength))
)

windows <- (selected
	|> select(loc, phase)
	|> distinct()
	|> mutate(start=-Inf, end=Inf)
)

summary(selected)

saveVars(long, selected, windows)
