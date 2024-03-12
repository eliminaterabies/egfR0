# this creates a bunch of not very helpful warnings and notes about which
# packages are being attached and conflicts that we expect and are fine with.
# NOT RUN: library(tidyverse)

# tidyverse suggests using the package **conflicted** to resolve these
# which is fine but it both requires yet another dependency, and also might be
# stricter than we typically need.

# another option is to use `options()` in base R to get desired behavior.
# for reference, https://developer.r-project.org/Blog/public/2019/03/19/managing-search-path-conflicts/


# a slightly more liberal version of the recommended recipe might be what we
# want. I think this will silence the annoyingest warnings (e.g., where
# individual packages from the tidyverse mask base functions) but keep other
# conflicts as *errors* rather than allowing them to be *warnings*. Also,
# loading `library(tidyverse)` triggers `tidyverse_conflicts()` to run, which
# can be silenced manually.

# The below is sufficient, but maybe more than necessary?

# Now, my options

## Over-ride base stuff silently (see “mask”). Make user resolve other conflicts
options(
	conflicts.policy = list(
		error = TRUE, warn = FALSE, generics.ok = TRUE
		, can.mask = c("base", "methods", "utils"
			, "grDevices", "graphics", "stats"
		)
		, depends.ok = TRUE
	)
	, tidyverse.quiet = TRUE
)

library(tidyverse) # silent, by default
# library(MASS) # throws an error, arguably desirable
library(MASS, exclude = "select")
message("I loaded MASS without error")
# library(dplyr)
# library(data.table) # again, with error that would need to be resolved
# END DONT RUN
