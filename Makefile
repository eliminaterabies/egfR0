## This is egfR0, a fresh new repo.
## The old rabies_R0 and historical_R0 repos are now deprecated

### Hooks 
current: target
-include target.mk

vim_session:
	bash -cl "vmt TODO.md README.md notes.md"

##################################################################

Sources += README.md notes.md ##
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

Sources += $(wildcard *.R *.stan)

rrun = $(stanVan)

######################################################################

Ignore += dogs.csv Human_CT.csv *_Check.csv

update_dogs:
	$(RM) dogs.csv
dogs.csv: | pipeline
	$(LNF) pipeline/SD_dogs.incubation.Rout.csv $@ 

######################################################################

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

check.Rout: check.R dogs.csv
	$(pipeR)


######################################################################

## Check Code for KH and reference code
slowtarget/check.Rout: dogs.csv check.R
	$(pipeR)

######################################################################
## 2023 Dec 25 (Mon)

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

mapStuff.Rout: mapStuff.R


######################################################################
## Need to repipe stuff below when we are happen with r_ests


combine_r_nb.Rout: combine_r.R slow/exp_nb.rds slow/cexp_nb.rds slow/logis_nb.rds growthfit_data.rda
	$(pipeR)

combine_r_plot.Rout: combine_r_nb.R combine_r_nb.rds
	$(pipeR)

simulate_growthcurve.Rout: simulate_growthcurve.R slow/growthrate.nb_stan.rds slow/exp_stan.rds growthfit_data.rda
	$(pipeR)

plot_growthrate.Rout: plot_growthrate.R growthrate_df.rds
	$(pipeR)

check_growthrate.Rout: check_growthrate.R simulate_growthcurve.rds growthfit_data.rda
	$(pipeR)

simR0_funs.Rout: simR0_funs.R
	$(pipeR)

R0est_funs.Rout: R0est_funs.R
	$(pipeR)

slowtarget/simR0.Rout: simR0.R slow/growthrate.nb_stan.rds once.rds simR0_funs.rda R0est_funs.rda
	$(pipeR)

slowtarget/simR0_combo.Rout: simR0_combo.R slow/growthrate.nb_stan.rds slow/exp_stan.rds once.rds simR0_funs.rda R0est_funs.rda
	$(pipeR)

KH_R0.Rout: KH_R0.R
	$(pipeR)

simR0_comboPlot.Rout: simR0_comboPlot.R slow/simR0_combo.rds KH_R0.rda
	$(pipeR)

simR0_comboPlot_all.Rout: simR0_comboPlot_all.R slow/simR0_combo.rds KH_R0.rda
	$(pipeR)

mexico.Rout: mexico.R simR0_comboPlot_all.rds KH_R0.rda
	$(pipeR)

simR0Plot_adj.Rout: simR0Plot_adj.R simR0_comboPlot.rds
	$(pipeR)

Ignore += eeid.html

Ignore += *.soc

SH.Rout: SH.R

exp_ll.Rout: impSamps.Rout bbmle/R/impsamp.Rout SH.Rout exp_ll.R
	$(run-R)

likelihood.Rout: likelihood.R

SH_stan.Rout: logistic.stan SH_stan.R
	$(run-R)

gamma_ll.Rout: gamma_ll.R
	$(run-R)

arctan.Rout: arctan.R

sampling_test.Rout: intervals.Rout simR0_funs.Rout sampling_test.R
	$(run-R)

sampling_testplot.Rout: sampling_test.Rout sampling_testplot.R
	$(run-R)

######################################################################

## What is this? Abandoned about a year before the ms.Rnw?

### Clean 

clean: 
	rm *.wrapR.r *.Rout *.wrapR.rout *.Rout.pdf

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
