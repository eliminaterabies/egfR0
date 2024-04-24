## This is egfR0, a fresh new repo. Jan 2024
## The old rabies_R0 and historical_R0 repos are now somewhat deprecated

### Hooks
current: target
-include target.mk

vim_session:
	bash -cl "vmt TODO.md README.md notes.md"

##################################################################

Sources += README.md notes.md TODO.md ##
Sources += .gitignore

Ignore += $(wildcard *.Rproj .Rproj.*)

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
Sources += $(wildcard *.bib)

## This is the main rule
## draft.pdf.final: rabies.bib draft.tex doc.Rnw
## draft.pdf: draft.tex doc.Rnw
Ignore += draft.pdf.final.pdf
draft.pdf.final.pdf: $(Sources)
	$(RM) $@
	$(MAKE) draft.pdf.final
	$(LN) draft.pdf $@

## This rule will try harder to make a pdf, and less hard to make sure all of the dependencies are in order. 
## draft.tex.pdf: draft.tex doc.Rnw
## Other dependencies should be in texknit/doc.tex.mk
draft.pdf: texknit/doc.makedeps doc.Rnw
texknit/doc.tex: msvalues

msvalues: delphi.pars.rda slow/bitten.rda slow/egf_R0.rda slow/intervals.rda

######################################################################

## Horrible diff pipeline, consider updating
## Need to make the dotdir doc you want manually
diff.doc.tex: dotdir/texknit/doc.tex texknit/doc.tex
	$(latexdiff)

Ignore += draft.diff.tex
draft.diff.tex: draft.tex
	$(latexdiff) $<
	
Ignore += diff.pdf
diff.pdf: diff.doc.tex draft.diff.tex
	$(MVF) $< texknit/doc.tex
	$(MAKE) draft.diff.pdf
	$(MVF) draft.diff.pdf $@
	$(RM) texknit/doc.tex

######################################################################

## Old diagnostic stuff, delete 2024 Apr 09 (Tue)
Sources += fake.tex fakedoc.Rnw
## fake.pdf: fake.tex fakedoc.Rnw

## supp.tex.pdf: supp.tex
## supp.pdf: supp.tex

Ignore += *.loc

## TODO: fancify and export both of these recipe lines ☺
.PRECIOUS: texknit/%.tex
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

Sources += generations.mk

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

## Conversion functions were used in the past by bitten, but may be unused now 2024 Mar 12 (Tue)
convert.Rout: convert.R
	$(pipeR)

bitten.Rout: bitten.R dogs.csv
	$(pipeR)

## slow can have bitten.rda, but not bitten.rds!!
slowtarget/bitten.rda: bitten.rda
	$(copy)

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
slowtarget/intervals.Rout: intervals.R incubation.rda once.rds 
	$(pipeR)

intervalPlots.Rout: intervalPlots.R slow/intervals.rda 
	$(pipeR)

######################################################################

## Check Code for KH and reference code
slowtarget/check.Rout: check.R dogs.csv
	$(pipeR)

######################################################################

## Old manual window-selection; new name-only list
Sources += series.tsv varnames.tsv

## Read two data sets into a long frame
## Trim out Excel padding; add time offsets
slowtarget/monthly.Rout: monthly.R datadir/R0rabiesdataMonthly.csv datadir/monthlyTSdogs.csv varnames.tsv
	$(pipeR)

######################################################################

## New window selection by algorithm and parameters

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
%.monthly_phase.Rout: monthly_phase.R slow/monthly.rds %.pars.rda 
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

## The last pre-Delphi comparison plot.
compare.Rout: compare.R softClimb.mm_plot.rds lowPeaks.mm_plot.rds base.mm_plot.rds softDecline.mm_plot.rds
	$(pipeR)

######################################################################

## Epigrowthfit

pipeRimplicit += egf_fit

## delphi.egf_fit.Rout: egf_fit.R
%.egf_fit.Rout: egf_fit.R %.mm_windows.rda
	$(pipeR)

######################################################################

## We've now selected Delphi and are sticking with it
## pipeRimplicit += egf_single

## Do an egf fit 

exp.Rout: exp.R
	$(pipeR)

logistic.Rout: logistic.R
	$(pipeR)

pipeRimplicit += egf_single

## exp.egf_single.Rout: egf_single.R
## logistic.egf_single.Rout: egf_single.R

%.egf_single.Rout: egf_single.R delphi.mm_windows.rda %.rda
	$(pipeR)

pipeRimplicit += egf_plot
## exp.egf_plot.Rout: egf_plot.R
## logistic.egf_plot.Rout: egf_plot.R
%.egf_plot.Rout: egf_plot.R %.egf_single.rds
	$(pipeR)

pipeRimplicit += egf_rplot

## exp.rplot.Rout:
## logistic.rplot.Rout:
%.rplot.Rout: rplot.R %.egf_single.rds
	$(pipeR)

rplot_combo.Rout: rplot_combo.R exp.egf_single.rds logistic.egf_single.rds series.tsv
	$(pipeR)

pipeRimplicit += egf_sample

simparams.Rout: simparams.R
	$(pipeR)

## exp.egf_sample.Rout: egf_sample.R
## logistic.egf_sample.Rout:
%.egf_sample.Rout: egf_sample.R %.egf_single.rds simparams.rda
	$(pipeR)

simR0_funs.Rout: simR0_funs.R
R0est_funs.Rout: R0est_funs.R

Sources += $(wildcard slow/*.rda slow/*.rds)

## slow/egf_R0.Rout: egf_R0.R R0est_funs.R simparams.R
## slowtarget/egf_R0.Rout: egf_R0.R simparams.R
slowtarget/egf_R0.Rout: egf_R0.R exp.egf_sample.rds logistic.egf_sample.rds simR0_funs.rda R0est_funs.rda slow/intervals.rda once.rds simparams.rda
	$(pipeR)

R0plot.Rout: R0plot.R slow/egf_R0.rda series.tsv
	$(pipeR)

KH_R0.Rout: KH_R0.R series.tsv slow/egf_R0.rda
	$(pipeR)

R0combo.Rout: R0combo.R KH_R0.rds R0plot.rds
	$(pipeR)

mexico.Rout: mexico.R slow/egf_R0.rda KH_R0.rds
	$(pipeR)

## Epigrowthfit version
version.Rout: version.R
	$(pipeR)

######################################################################

allslow = $(wildcard slow/*)
slowfinal = $(allslow:slow/%=slowtarget/%.final) ;
slowfinal: $(slowfinal)

## Graphing (weird stuff, and acting weird for now)

## draft.pdf.fast.mg.pdf: 
## slowfinal.mg.pdf:

Ignore += *.ndlog
%.ndlog: Makefile
	make -nd $* > $@

Ignore += *.cleanlog
%.cleanlog: %.ndlog
	cat $< | grep -v makestuff | grep -v "\.mk" | grep -v makedeps | grep -v subdeps > $@

%.fast.cleanlog: %.cleanlog
	cat $< | grep -v slowtarget > $@

Ignore += *.mg.dot
%.mg.dot: %.cleanlog
	make2graph $< > $@

Ignore += *.mg.pdf
%.pdf: %.dot
	dot -Tpdf -o $@ $<

## Does not chain through wildcard; also, the graph has unexplained orphanism
%.dd.cleanlog: %.dd.testsetup $(wildcard %.dd/*.*)
	cd $*.dd && $(MAKE) $*.cleanlog
	$(CP) $*.dd/$*.cleanlog $@

######################################################################

## for stuff that may need to be rebuilt
## See also generations.mk
Sources += content.mk

##################################################################

### Makestuff

Sources += Makefile

Ignore += makestuff
msrepo = https://github.com/dushoff

Makefile: makestuff/06.stamp
makestuff/%.stamp:
	- $(RM) makestuff/*.stamp
	(cd makestuff && $(MAKE) pull) || git clone --depth 1 $(msrepo)/makestuff
	touch $@

-include makestuff/os.mk

-include makestuff/texi.mk
-include makestuff/pandoc.mk
-include makestuff/pipeR.mk
-include makestuff/slowtarget.mk

-include makestuff/git.mk
-include makestuff/visual.mk
