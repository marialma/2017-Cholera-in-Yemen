rm(list = ls())
library(dplyr)
library(ggplot2)
setwd("~/Documents/GitHub/2017-Cholera-in-Yemen")
choleradata <- read.csv("Yemen Cholera Outbreak Epidemiology Data - Data_Governorate_Level.csv")
yemendata <- read.csv("ydp.csv")

### The next part of this is a massive work in progress ###

#Subsetting out hospital airstrikes from overall airstrike data
hospitals <- subset(yemendata, Main.category == "Medical_Facility")

hospitals <- droplevels(hospitals)

#writing to CSV
write.csv(hospitals, file = "2017YemenHospitalAirstrike.csv")

hospitals <- transmute(hospitals, Date, Governorate, Target, Sub.category)
hospitals <-  rename(hospitals, facility_type = "Sub.category")

hospitals <- droplevels(hospitals)
levels(hospitals$Governorate) <- c("Abyan", "Aden", "Amran", "Al Bayda", "Sana'a", "Hajjah", "Al Hudaydah", "Lahj", "Marib", "Sa'ada", "Sana'a", "Shabwah", "Taizz")

#writing to CSV
write.csv(hospitals, file = "2017YemenHospitalAirstrike.csv")



rm("choleradata", "hadramaut", "yemendata")

# Number of times each governorate had a hospital that was bombed

bombings <- hospitals$Governorate %>% 
  unlist %>% 
  table %>% 
  as.data.frame

bombings <- rename(bombings, Governorate = ".") ## probably a more efficient way to do this part


cholera <-  rename(cholera, Governorate = "COD") ## should have done this earlier, but now i'm being lazy.

#combining bombing dataset with cholera dataset - want to see ARs
#in areas that got bombed

test <- subset(cholera, cholera$Date == "2017-05-22")
test <- subset(test, select = c(Governorate, attack_rate))

miniset <- merge(test,bombings)

cholera2 <- subset(cholera, select = c(Date, Governorate, attack_rate))
govs <- merge(cholera2,bombings)
###############
# Correlation #
###############

cor(miniset$Freq, miniset$attack_rate)