## R0 estimate functions
library(shellpipes)


#Functions to estimate R0 and CIs via data
R0est_data<-function(r, interval){
  return(
    1/mean(exp(-r*interval))
  )
}

genExp <- function(rho, kappa){
  if (kappa==0)
    return(exp(rho))
  return((1+rho*kappa)^(1/kappa))
}

genExpGamma <- function(r, Mean, Shape){
  return(genExp(r*Mean, 1/Shape))
}


R0est_gamma <-function(r, timedat){
  Mean <- timedat[2]
  Shape <- timedat[1]
  return(genExp(r*Mean, 1/Shape))
}

saveEnvironment()

