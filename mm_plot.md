
Since our last meeting, WZ and I have:

* tried to make the pictures easier to read
* changed the cut algorithm to not cut until a local minimum is reached; this seems to “just fix” Kanagawa
* made a pipeline that should make it relatively easy to compare different parameter choices (see links below)

Questions:

* The first window in Kanagawa has a double peak; JD feels like we should not fiddle
* The second phase in Kanagawa is sensitive to minPeak choice
* Memphis looks like a good peak, but is not selected because the time series is too short
* We kind of want to exclude Perak; we could do that by raising the minimum to 16, or just by making a judgment that we hate it
* Tokyo1 has two double peaks!
* What do we think about the first peak in Tokyo2?

You can view some pictures [here](outputs/compare.Rout.pdf); the pipeline makes it easy now to change parameters and make comparisons.

It would be great it you could share any quick thoughts, and really great if we could make decisions when we meet on Monday.

