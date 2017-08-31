rm(list = ls())
library(dplyr)
setwd("~/Documents/Yemen Cholera")
choleradata <- read.csv("Yemen Cholera Outbreak Epidemiology Data - Data_Governorate_Level.csv")

# Dropping unnecessary variables. There's probably a less dumb way to do this.

cholera <- mutate(choleradata,COD.Gov.Arabic = NULL) %>%
  mutate(COD.Gov.Pcode = NULL) %>%
  mutate(Governorate = NULL)

# Renaming variables to be easier to type

cholera <-  rename(cholera, 
         attack_rate = "Attack.Rate..per.1000.",
         case_fatality = "CFR....",
         COD = "COD.Gov.English")

#R is reading in this CSV with the cases as characters instead of numeric
# because some of the numbers have commas. This is to remove those

cholera$Cases <- gsub(",", "", cholera$Cases)
cholera$Cases <- cholera$Cases %>% as.character %>% as.numeric
cholera$Date <- cholera$Date %>% as.character %>% as.Date

# Data downloaded as of 8/28 is inconsistent - attack rates are off by a factor of 10. This isn't real;
# I checked against the original data to confirm this. So, gotta fix that. 
# Divide attack rate by 10 for entries after Aug 14th. Is there a way to detect this automatically?

cholera <- mutate(cholera, attack_rate = ifelse(cholera$Date > "2017-08-14", attack_rate/10, attack_rate))

# Hadramaut is split into Say'on and Moklla, but data for this isn't available until after July. 
# Say'on and Moklla data, conveniently, are labeled as #N/A in COD.Gov.English. 

hadramaut <- cholera %>%
  filter(COD == "#N/A") %>%
  group_by(Date) %>%
  summarise(Cases = sum(Cases), Deaths = sum(Deaths), case_fatality = mean(case_fatality), attack_rate = mean(attack_rate), COD = "Hadramaut")

# summarise won't let me recalculate CFRs, since "deaths/cases" is not a summary statistic, I guess?
# so now, I'm going to replace them. Rounding to make it consistent with the rest of the data 
hadramaut$case_fatality <- round((hadramaut$Deaths/hadramaut$Cases)*100, digits = 2)

#converting COD to factors so I can bind it back in.

cholera$COD <- as.character(cholera$COD)

# next, within "cholera", subset out all #N/A in COD, and bind "hadramaut" to it. 
cholera <- cholera %>%
  subset(COD != "#N/A") %>%
  bind_rows(hadramaut)
cholera$COD <- as.factor(cholera$COD)

# Figure out new daily cases. This part was unashamedly taken from someone on stackexchange.
cholera <- cholera %>%
  group_by(COD) %>%
  arrange(Date) %>%
  mutate(newcases = Cases - lag(Cases, default=0))

#write to CSV
write.csv(cholera, file = "2017YemenCholera.csv")
