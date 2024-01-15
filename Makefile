## This is egfR0, a fresh new repo. Jan 2024
## The old rabies_R0 and historical_R0 repos are now somewhat deprecated

### Hooks 
current: target
-include target.mk

vim_session:
	bash -cl "vmt TODO.md README.md notes.md monthly.md"

##################################################################

Sources += README.md notes.md TODO.md ##

######################################################################

## Use Dropboxes to pass and cache data so that we can keep the code open

## Make a local.mk (locally ☺) if you want to reset the Dropbox base directory
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

Sources += $(wildcard *.R)

## Moved a whole bunch of generations stuff
## See also content.mk

Sources += generations.mk

######################################################################

## Temporary section for managing conflicts
## Goal is to
#### suppress the non-warning text and to
#### eliminate the warnings, but in a principled way
###### i.e., we don't want to miss any warnings that are coming

conflicts.Rout: conflicts.R
	$(pipeR)

######################################################################

Ignore += dogs.csv

Sources += series.tsv varnames.tsv
Sources += monthly.md ## A statistical practice journal

## Read two data sets into a long frame
## Trim out Excel padding; add time offsets
monthly.Rout: monthly.R datadir/R0rabiesdataMonthly.csv datadir/monthlyTSdogs.csv varnames.tsv
	$(pipeR)

######################################################################

windowPars.Rout: windowPars.R
	$(pipeR)

softPars.Rout: softPars.R
	$(pipeR)

hardPars.Rout: hardPars.R
	$(pipeR)

## Break series into phases
## Uses parameters minPeak and declineRatio
pipeRimplicit += monthly_phase

## hardPars.monthly_phase.Rout: monthly_phase.R
## softPars.monthly_phase.Rout: monthly_phase.R
%.monthly_phase.Rout: monthly_phase.R monthly.rds %.rda
	$(pipeR)


## Multiple monthly windows per data set sometimes
## Uses parameters minPeak (again),  minLength, and minClimb
pipeRimplicit += mm_windows

## hardPars.mm_windows.Rout: mm_windows.R
## softPars.mm_windows.Rout: mm_windows.R
%.mm_windows.Rout: mm_windows.R monthly_phase.rda %.rda
	$(pipeR)


pipeRimplicit += mm_plot

## hardPars.mm_plot.Rout: mm_plot.R
## softPars.mm_plot.Rout: mm_plot.R
%.mm_plot.Rout: mm_plot.R %.mm_windows.rda
	$(pipeR)

######################################################################

## Explore different windowing parameter choices

######################################################################

## Epigrowthfit

egf.Rout: egf.R mm_windows.rda
	$(pipeR)

egf_indep.Rout: egf_indep.R mm_windows.rda
	$(pipeR)

## for stuff that may need to be rebuilt
## See also generations.mk
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
