
Need to fill in from recent notes about choosing windows

2024 Jan 03 (Wed)
=================

What do we want to do about random effects, etc?

Doing REs at the country level feels like a nightmare: possibly to fit, but also to interpret. During REs only at the phase level seems impossible (not enough info, and the additivity assumption is confusing).

So we are thinking for now of estimating r0 separately for each time series.

Another question is whether we want to estimate r0 at t=-∞, or at a time when the cumulative cases are estimated at 1. How much difference does it make? JD thinks it probably matters for some formulations but not others. Logistic seems stable-ish, so maybe stick with that. Meaning also: stick with egf, which does t=-∞.

2023 Dec 25 (Mon)
=================

Our new pipeline has three parameters that are used in window selection. The first set we looked at was minPeak=12; ratThresh=0.25 and minLength=6.

We decided quickly that minLength=6 was too big a departure from past work, and switched to minLength=5.

First set of observations:
* We don't like the second phase of Kanagawa (it goes down almost as much as up); we could consider tweaking ratThresh (or adding something else) to trim the beginning. We could also consider increasing minPeak a little bit to drop it
* We think we're OK with losing Memphis, but should talk to Katie
* Perak is another argument for increasing minPeak
* Perak also points to a potential flaw in the algorithm; what should we do when the point-after-peak (which we want for egf) is classified as a separate phase. For now, we are dropping it, which doesn't seem stupid, but we should definitely not that we are doing that if we are.
* Serengeti phase 2 is keeping a double wave as one outbreak (because ratThresh is low; is that what we want?)
* Tokyo1 looks like a big mess to JD (both outbreaks are long and complicated)
