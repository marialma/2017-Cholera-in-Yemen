rm(list = ls())
library(dplyr)
library(ggplot2)
setwd("~/Documents/GitHub/2017-Cholera-in-Yemen")
choleradata <- read.csv("Yemen Cholera Outbreak Epidemiology Data - Data_Governorate_Level.csv")

######################
# Getting data ready #
######################


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

cholera$Cases <- (gsub(",", "", cholera$Cases)) 
cholera$Cases <- cholera$Cases %>% as.character %>% as.numeric
cholera$Date <- cholera$Date %>% as.character %>% as.Date

# Data downloaded as of 8/28 is inconsistent - attack rates are off by a factor of 10. This isn't real;
# I checked against the original data to confirm this. So, gotta fix that. 
# Divide attack rate by 10 for entries after Aug 14th. Is there a way to detect this automatically?

# cholera <- mutate(cholera, attack_rate = ifelse(cholera$Date > "2017-08-14", attack_rate/10, attack_rate))

# Editing to add: This error was fixed in subsequent versions of the dataset. 

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

# Figure out new daily cases.
#cholera <- cholera %>%
#  group_by(COD) %>%
#  arrange(Date) %>%
#  mutate(newcases = Cases - lag(Cases, default=0))

cholera <- mutate(cholera, case_fatality = round((Deaths/Cases)*100, 1))
#write to CSV
#write.csv(cholera, file = "2017YemenCholera.csv")

#################
# Visualization #
#################

library(gganimate)
library(tidyverse)
cholera2 <- transmute(cholera, Date= Date, Cases = Cases, COD = COD)
cholera2 <- spread(cholera2, Date, Cases) #this has to be done to introduce NA values so the map animation doesn't have empty space
cholera2 <- gather(cholera2, "Date", "Cases", -1)
cholera2$Date <- as.Date(cholera2$Date)

library(directlabels)
ggplot(cholera2, aes(x=Date, y= Cases, color = COD)) + geom_line() + theme_minimal() +
  theme(legend.position = "none")  +
  scale_x_date(limits = as.Date(c('2017-05-22','2018-04-01'))) +
  geom_dl(aes(label = COD), method = list("last.points", cex = 0.8)) + labs( title = "Cumulative Cholera Cases in Yemen, by Governorate",
                                                                             caption = "Data from WHO situation reports")
ggsave("linechart.png", width = 6, height = 5, units = "in")

library(sf)
yemen1 <- read_sf("yemen_admin_20171007_shape")
yemen1 <- transmute(yemen1, COD = name_en, geometry = geometry)
map2 <- right_join(yemen1, cholera2)


map2 <- map2 %>%
  group_by(Date) %>%
  arrange(COD) 

map2 <- map2 %>%
  group_by(COD) %>%
  arrange(Date) 

yemen_cases <- ggplot(map2) + geom_sf(aes(fill = Cases), color = "black") +
  scale_fill_viridis_c(na.value = "grey") + 
  transition_time(Date) + labs(title = "Cumulative Cholera Cases: {frame_time}") + theme_void()

img <- animate(yemen_cases)
anim_save("Yemen_Cases.gif")


#Animate: Attack Rate
cholera3 <- transmute(cholera, Date= Date, attack_rate = attack_rate, COD = COD)
cholera3 <- spread(cholera3, Date, attack_rate) #this has to be done to introduce NA values so the map animation doesn't have empty space
cholera3 <- gather(cholera3, "Date", "attack_rate", -1)
cholera3$Date <- as.Date(cholera3$Date)
map3 <- right_join(yemen1, cholera3)

map3 <- map3 %>%
  group_by(Date) %>%
  arrange(COD) 

map3 <- map3 %>%
  group_by(COD) %>%
  arrange(Date) 

yemen_AR <- ggplot(map3) + geom_sf(aes(fill = attack_rate), color = "black") +
  scale_fill_viridis_c(na.value = "grey") + 
  transition_time(Date) + labs(title = "Cholera Attack Rate: {frame_time}") + theme_void()

img <- animate(yemen_AR)
anim_save("Yemen_AR.gif")


ggplot(cholera) + geom_area(aes(x=Date, y= Deaths, fill = COD)) + 
  theme(legend.position = "bottom") 
