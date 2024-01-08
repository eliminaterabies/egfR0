## This is egfR0, a fresh new repo.
## The old rabies_R0 and historical_R0 repos are now deprecated

### Hooks 
current: target
-include target.mk

vim_session:
	bash -cl "vmt TODO.md README.md notes.md"

##################################################################

Sources += README.md notes.md TODO.md ##

######################################################################

## Use Dropboxes to pass and cache data so that we can keep the code open

Ignore += local.mk
Drop = ~/Dropbox
-include local.mk

## Original data
Ignore += datadir
datadir/%:
	$(MAKE) datadir
datadir: dir=$(Drop)/Rabies_TZ/
datadir:
	$(linkdirname)

## Pipeline outputs
Ignore += pipeline
pipeline/%:
	$(MAKE) pipeline
pipeline: dir=$(Drop)/Rabies_TZ/pipeline/SD_dogs/
pipeline:
	$(linkdirname)

##################################################################

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
check.Rout: dogs.csv check.R
	$(pipeR)

######################################################################
## 2023 Dec 25 (Mon)

Sources += series.tsv varnames.tsv
Sources += monthly.md ## A statistical practice journal

## Read two data sets into a long frame
## Trim out Excel padding; add time offsets
monthly.Rout: monthly.R datadir/R0rabiesdataMonthly.csv datadir/monthlyTSdogs.csv varnames.tsv
	$(pipeR)

## Break series into phases
## This is based on parameters: minPeak and ratThresh
monthly_phase.Rout: monthly_phase.R monthly.rds
	$(pipeR)

## Multiple monthly windows per data set sometimes
## Depends on yet another parameter, 
mm_windows.Rout: mm_windows.R monthly_phase.rda
	$(pipeR)

mm_plot.Rout: mm_plot.R mm_windows.rda
	$(pipeR)

egf.Rout: egf.R mm_windows.rda
	$(pipeR)

egf_indep.Rout: egf_indep.R mm_windows.rda
	$(pipeR)

## for stuff that may need to be rebuilt
Sources += content.mk

##################################################################

### Makestuff

Sources += Makefile

Ignore += makestuff
msrepo = https://github.com/dushoff

Makefile: makestuff/02.stamp
makestuff/%.stamp:
	- $(RM) makestuff/*.stamp
	(cd makestuff && $(MAKE) pull) || git clone --depth 1 $(msrepo)/makestuff
	touch $@

-include makestuff/os.mk
-include makestuff/slowtarget.mk

-include makestuff/texi.mk
-include makestuff/pandoc.mk
-include makestuff/pipeR.mk

-include makestuff/git.mk
-include makestuff/visual.mk
