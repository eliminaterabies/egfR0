library(shellpipes)

convertDay <- Vectorize(function(x){
  if(x==""){return(NA)}
  if(x=="Day"){return(1)}
  if(x=="Week"){return(7)}
  if(x=="Month"){return(365.25/12)}
  stop("Can't convert unit", x)
})

intervalBound <- function(x){
  return(convertDay(x)/2)
}

saveVars(convertDay, intervalBound)
