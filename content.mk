
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

## Remember we are not slow anymore ☺ 2024 Jan 05 (Fri)
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

