library(dplyr)
setwd("~/Documents/Yemen Cholera")

choleradata <- read.csv("Yemen Cholera Outbreak Epidemiology Data - Data_Governorate_Level.csv")

# Dropping unnecessary variables. There's probably a more elegant way to do this.
cholera <- mutate(choleradata,COD.Gov.Arabic = NULL) %>%
  mutate(COD.Gov.Pcode = NULL)

# Renaming variables to be easier to type
cholera <-  rename(cholera, 
         attack_rate = "Attack.Rate..per.1000.",
         case_fatality = "CFR....",
         COD = "COD.Gov.English")

#R is reading in this CSV with the cases as characters instead of numeric
# because some of the numbers have commas. This is to remove those

cholera$Cases <- (gsub(",", "", cholera$Cases)) 
cholera$Cases <- cholera$Cases %>% as.character %>% as.numeric
cholera$Date <- cholera$Date %>% as.character %>% as.Date

# divide attack rate by 10 for entries after Aug 14th. Is there a way to detect this automatically?
cholera <- mutate(cholera, attack_rate = ifelse(cholera$Date > "2017-08-14", attack_rate/10, attack_rate))

# Things to do: 
# merge Say'on and Moklla data 
had <- cholera %>%
  filter(COD == "#N/A") %>%
  group_by(Date)

had2 <- had %>%
  summarise(COD = "Hadramaut", Cases = sum(Cases), Deaths = sum(Deaths), case_fatality = mean(case_fatality), attack_rate = mean(attack_rate))

# Figure out new daily cases
cholera <- cholera %>%
  group_by(Governorate) %>%
  arrange(Date) %>%
  mutate(diff = Cases - lag(Cases, default=first(Cases)))

