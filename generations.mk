## Link to Tanzanian data used for Generation intervals

Ignore += dogs.csv

update_dogs:
	$(RM) dogs.csv
dogs.csv: | pipeline
	$(LNF) pipeline/SD_dogs.incubation.Rout.csv $@ 

######################################################################

## Generation intervals

Sources += $(wildcard *.R)

## Interval stuff from TZ data
## Linking events

## Make events, put them together, calculate some different kinds of interval
## Still more intervals are needed. In particular, date-based infection _lags_
## i.e., Biting.time-Symptom time. These can be used for _hybrid_ interval calculations

## Make a table of events, and count how many times each animal was bitten
## makes table bitten

convert.Rout: convert.R
	$(pipeR)

bitten.Rout: bitten.R dogs.csv convert.rda
	$(pipeR)

## check.Rout: check.R

## Link events to parallel events for the upstream biter
## Produces table links
linked.Rout: linked.R bitten.rds
	$(pipeR)

## Calculate various intervals
## Produces table intervals

## Triage: let's isolate and begin to address the most obvious problems
## Get rid of them and look for the next level of problems
## At the same time: track with Katie 

## NOTE: Identify and eliminate outliers
## work on the scale and/or y=x line so we can see matching clearly
calcs.Rout: calcs.R linked.rda
	$(pipeR)

## Filter intervals to drop animals bitten more than once
## (focal and biters)
## Keep the same table name for flexibility downstream

once.Rout: once.R calcs.rda
	$(pipeR)

incubation.Rout: incubation.R once.rds
	$(pipeR)

incubationPlot.Rout: incubationPlot.R incubation.rda
	$(pipeR)

######################################################################

Sources += $(wildcard *.Rscript)
## intervals.allR: 
## intervals.Rscript: intervals.pipeR.script

## intervals.pipeR.script:
intervals.Rout: intervals.R incubation.rda once.rds 
	$(pipeR)

intervalPlots.Rout: intervalPlots.R intervals.rda 
	$(pipeR)

######################################################################

## Check Code for KH and reference code
check.Rout: check.R dogs.csv
	$(pipeR)

