library(tidyverse)
library(shellpipes)

loadEnvironments()

softClimb <- rdsRead("softClimb")
lowPeaks <- rdsRead("lowPeaks")

diffdat <- (bind_cols(softClimb$long,lowPeaks$long))

print(diffdat)


