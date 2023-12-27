2023 Dec 25 (Mon)
=================

Maybe we should put this on hold. What will it take to finish it?

1) Finish windowing (see Oct notes)

2) Apply epigrowthfit

3) re-assess

JD rebuilt a data-processing pipeline, there are some sharp questions in monthly.md. We need to talk to Katie about this.

ML tried some egf experiments, but JD is pretty unhappy about the window interface and the window logic; we should talk to Mikael.

… We have hacked around the window stuff, but there is too much we don't understand about egf; should try to meet with Mikael instead of making ourselves crazy.

2023 Oct 27 (Fri)
=================

We want the comparison with old window choices to be a side branch

JD wants to pre-screen series and break things with two “obvious” peaks

Mike wants to drop NYstate because it's not in the paper
* Can we cite it? Is the data set public?
* Mike: We can cite it, it is here. Note, KH did not have NYstate in the 2009 paper. The citation include both Central NY (in KH's paper) and NYstate (not in KH's paper). 
* https://ajph.aphapublications.org/doi/epdf/10.2105/AJPH.38.1_Pt_1.50


Set minmax (variable minPeak) to 12 which excludes HK, but maybe it should be a bit higher see below

Some thoughts:
• Break things that look like they have two peaks into two series
• Consider a slightly higher break either in general or for split series (worried about two fits for Serengeti)
• Should we start the second TS one step before the trough to avoid a bias that comes from starting from the very lowest point – we think yes
* Should there be a criterion for window length? Yes TODO when we do the splitting
* Note that we are taking old windows and splitting them. This means that we've thrown away anything after the global peak before we split.

2023 Oct 18 (Wed)
=================
We are revisiting data series and window choices.

There are at least 3 data series that never have >10 cases per month. Can we just throw them out?? Yes.

Multi-peak
* Kanagawa looks OK (we pick the first peak automatically)
* Tokyo (Tokyo1 is the new name) wants to pick a two-peak window, so we need to do something
* NYstatecounties seems similar to Tokyo

Let's take a look first at the old window selections
* Still happy with throwing out 3 series that have <10 cases in each month
* Serengeti does not peak; will change the code to use it up until the end
* Tokyo2 also fluctuates wildly within window, maybe drop it manually?
* NYstate used to use the small first peak.

Conclusion for the day:
* auto-drop 3 small series (<10 cases as the max)
* Fix serengeti limit
* worry about Tokyo1, Tokyo2, NYstate
