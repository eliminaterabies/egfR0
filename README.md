# egfR0

## Current plan

We are using the slow/ slowtarget/ pair _both_ for faster compilation, _and_ for sharing non-sensitive files that people can use to replicate the downstream part of our work.

Note that bitten.rds contains dog-specific information, and should not be share (unlike bitten.rda, which has only summary inforamton)

## to get up and running...

### re: make
To run code in this repo using the Makefile, use shellpipes
remotes::install_github("dushoff/shellpipes")
https://dushoff.github.io/shellpipes/

To pull and push (on git) idiomatically, simply run in terminal `make sync`.

### other R packages
I think I installed epiGrowthFit manually/outside the make file, but don't
recall -MER 20240130

## Documents and documentation
- `TODO.md` contains some long-term desiderata from JD
- `notes.md` contains meeting notes from meetings primarily between JD, KH, and ML
- `README.md` (this document) is where MR is writing user notes as he gets to know the project...
- `Makefile` describes workflows. 
- Not in this repo, but to understand the **make** workflows, it may help to see the **shellpipes** package documentation: https://dushoff.github.io/shellpipes/. for more, https://github.com/mac-theobio/useMakestuff
- `makestuff/README.md` has lots of **make** documentation
