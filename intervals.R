## Interval dataframe and merged interval-incubation dataframe

library(bbmle)
library(ggplot2)
library(dplyr)
library(purrr)
library(tidyr)
library(cowplot)
library(ggforce)
library(shellpipes)
theme_set(theme_bw())

loadEnvironments()

maxDays <- 1000
minDays <- 0
tidyInts <- (rdsRead()
	%>% select(dateSerial
		, dateGen
		)
	%>% gather(key=Type,value=Days, everything())
	%>% filter(between(Days, minDays, maxDays)) ## experimenting removing outliers
)

print(dim(tidyInts))
## taking out wait time
#wait_times <- tidyInts %>% filter(Type == "wait_time")


interval_df <- (tidyInts
	%>% transmute(Type = ifelse(grepl("Serial",Type),"Serial","Generation")
      	, Days
		)
	%>% group_by(Type)
	%>% mutate(Mean = mean(Days, na.rm=TRUE)
		, SD = mean(Days, na.rm=TRUE)
		)
)

interval_merge <- (interval_df
	%>% bind_rows(.,incubations)
	%>% ungroup()
	%>% mutate(Type = factor(Type, levels=c("Serial","Generation"
		, "Dogs", "Biter_rep", "Non-Biter", "Biter")
		, labels=c("Serial Interval", "Generation Interval"
			, "Incubation Period: Dogs"
			, "Weighted Incubation Period"
			, "Incubation Period: Non-Biter"
			, "Incubation Period: Biter"
		)
	))
)

bites <- (bites |> transmute(count=count))

print(interval_merge %>% select(-Days) %>% distinct())

print(interval_merge %>% group_by(Type) %>% summarise(count = n()))

saveVars(interval_merge, bites)
