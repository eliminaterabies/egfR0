## This is egfR0, a fresh new repo. Jan 2024
## The old rabies_R0 and historical_R0 repos are now somewhat deprecated

### Hooks
current: target
-include target.mk

vim_session:
	bash -cl "vmt TODO.md README.md notes.md"

##################################################################

Sources += README.md notes.md TODO.md ##

Ignore += .gitignore $(wildcard *.Rproj .Rproj.*)

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

## Pipeline outputs (different pointer inside the same Dropbox)
Ignore += pipeline
pipeline/%:
	$(MAKE) pipeline
pipeline: dir=$(Drop)/Rabies_TZ/pipeline/SD_dogs/
pipeline:
	$(linkdirname)

#################################################################

## Compile MS
Sources += doc.Rnw knitr.tex draft.tex

## draft.tex.pdf: draft.tex doc.Rnw
## draft.pdf: draft.tex doc.Rnw
draft.pdf: texknit/doc.makedeps

## supp.tex.pdf: supp.tex
## supp.pdf: supp.tex

texknit/doc.tex: check.rda

Ignore += *.loc

## TODO: fancify and export both of these recipe lines ☺
texknit/%.tex: %.Rnw | texknit
	Rscript -e "library(\"knitr\"); knit(\"$<\")"
	$(MVF) $*.tex texknit

Ignore += texknit
texknit:
	$(mkdir)

##################################################################

Sources += $(wildcard *.R)

## Moved a whole bunch of generations stuff
## See also content.mk

-include generations.mk
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

## Why did I put this back here from one of the resting files??
## Ignore += dogs.csv

######################################################################

## Old manual window-selection; new name-only list
Sources += series.tsv varnames.tsv

## Read two data sets into a long frame
## Trim out Excel padding; add time offsets
monthly.Rout: monthly.R datadir/R0rabiesdataMonthly.csv datadir/monthlyTSdogs.csv varnames.tsv
	$(pipeR)

######################################################################

autopipeR=defined

## Parameter sets
## delphi.pars.Rout: delphi.R
## softClimb.pars.Rout: softClimb.R
## softDecline.pars.Rout: softDecline.R
## lowPeaks.pars.Rout: lowPeaks.R


## Not sure if this is needed 2024 Jan 17 (Wed)
pipeRimplicit += pars
%.pars.Rout: pars.R base.R %.R
	$(pipeR)

## Break series into phases
## Uses parameters minPeak and declineRatio
pipeRimplicit += monthly_phase

## Split time series into phases
## softClimb.monthly_phase.Rout: monthly_phase.R
%.monthly_phase.Rout: monthly_phase.R monthly.rds %.pars.rda 
	$(pipeR)

## Identify windows inside the phases
## Uses parameters minPeak (again),  minLength, and minClimb
pipeRimplicit += mm_windows

## Read pars again why?
## softClimb.mm_windows.Rout: mm_windows.R
%.mm_windows.Rout: mm_windows.R %.monthly_phase.rda %.pars.rda
	$(pipeR)

pipeRimplicit += mm_plot

## base.mm_plot.Rout: mm_plot.R
## delphi.mm_plot.Rout: mm_plot.R
## lowPeaks.mm_plot.Rout: mm_plot.R
%.mm_plot.Rout: mm_plot.R %.mm_windows.rda %.pars.rda
	$(pipeR)

## This code is terrible; pull ugly stuff out of mm_plot and make it nice 2024 Jan 24 (Wed)
## This is apparently the last, pre-Delphi comparison plot.
compare.Rout: compare.R softClimb.mm_plot.rds lowPeaks.mm_plot.rds base.mm_plot.rds softDecline.mm_plot.rds
	$(pipeR)

## This is apparently a dead end and I want to kill it 2024 Feb 21 (Wed)
comp.Rout: comp.R softClimb.mm_windows.rda lowPeaks.mm_windows.rda
	$(pipeR)

Sources += mm_plot.md

######################################################################

## Explore different windowing parameter choices

######################################################################

## Epigrowthfit

## delphi.egf_fit.Rout: egf_fit.R
%.egf_fit.Rout: egf_fit.R %.mm_windows.rda
	$(pipeR)

######################################################################

## We've now selected Delphi and are sticking with it
## pipeRimplicit += egf_single

## Do an egf fit 
egf_single.Rout: egf_single.R delphi.mm_windows.rda
	$(pipeR)

egf_plot.Rout: egf_plot.R egf_single.rds
	$(pipeR)

rplot.Rout: rplot.R egf_single.rds
	$(pipeR)

egf_sample.Rout: egf_sample.R egf_single.rds
	$(pipeR)

simR0_funs.Rout: simR0_funs.R
R0est_funs.Rout: R0est_funs.R

## egf_R0.Rout: egf_R0.R R0est_funs.R
egf_R0.Rout: egf_R0.R egf_sample.rds simR0_funs.rda R0est_funs.rda intervals.rda
	$(pipeR)

R0plot.Rout: R0plot.R egf_R0.rds series.tsv
	$(pipeR)

KH_R0.Rout: KH_R0.R varnames.tsv egf_R0.rds
	$(pipeR)

R0combo.Rout: R0combo.R KH_R0.rds R0plot.rds
	$(pipeR)


## Epigrowthfit version
version.Rout: version.R
	$(pipeR)

######################################################################

## for stuff that may need to be rebuilt
## See also generations.mk
Sources += content.mk

##################################################################

### Makestuff

Sources += Makefile

Ignore += makestuff
msrepo = https://github.com/dushoff

Makefile: makestuff/03.stamp
makestuff/%.stamp:
	- $(RM) makestuff/*.stamp
	(cd makestuff && $(MAKE) pull) || git clone --depth 1 $(msrepo)/makestuff
	touch $@

-include makestuff/os.mk

-include makestuff/texi.mk
-include makestuff/pandoc.mk
-include makestuff/pipeR.mk

-include makestuff/git.mk
-include makestuff/visual.mk
