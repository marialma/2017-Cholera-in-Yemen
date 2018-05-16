# Quick and Dirty Model of Cholera Outbreak
# Maria Ma
#
# Isaac Fung wrote a fantastic paper in 2014 on Cholera transmission dynamic models for public health practitioners (1)
# Most of this is a quick and dirty attempt to use that model to look at Yemen's cholera outbreak
# A paper looking at this outbreak was previously published in mid-2017 from Nishiura et al (2)

# Thank you to Dr. John Marshall for teaching me this stuff. Sorry I have not applied it super well.

# # still need to do: import epi curve from WHO data. fit curve to model 
# 

rm(list=ls())
setwd("~/Documents/GitHub/2017-Cholera-in-Yemen/ODE")
library(deSolve)

cholera <- function(time, state, parameters) {
  ## parameters
  rec <- 1 / infP
  infP <- 5 # estimated infectious period from Fung et al. Range is 2.9-14, but 5 is most commonly reported.
  mu <- 0.002 # actual death rate
  xi <- parameters["contamRate"]
  del <- parameters["cleanRate"]
  beta <- parameters["contactRate"]
  chi <- 500000 #concentration that yields 50% chance of infection. From Fung et al
  ## states
  S <- state["S"]
  I <- state["I"]
  R <- state["R"]
  B <- state["B"]
  N <- S + I + R
  dS <- -(beta * (B / (B + chi))) * S
  dI <- (beta * (B / (B + chi))) * S - rec * I - mu * I 
  dR <- rec * I
  dB <- xi * I - del * B

  return(list(c(dS, dI, dR, dB)))
}


# References: ----
# 1) https://ete-online.biomedcentral.com/articles/10.1186/1742-7622-11-1
# 2) https://tbiomed.biomedcentral.com/articles/10.1186/s12976-017-0061-x

# Import Data ----
# Source: https://data.humdata.org/dataset/yemen-cholera-outbreak-daily-epidemiology-update, http://www.emro.who.int/images/stories/yemen/cholera_week_2.pdf?ua=1
library(plyr)
library(dplyr)
library(reshape2)
# The following commented-out code produces an epi curve, but it doesn't look like what the WHO has reported as their official epi curve.----
# choleradata <- read.csv("Yemen Cholera Outbreak Epidemiology Data - Data_Country_Level.csv") 
#choleradata <- transmute(choleradata, Date, Cases, Deaths, cfr = CFR...., attack_rate = Attack.Rate..per.1000.)

#get week number 
#choleradata$Date <- as.Date(choleradata$Date)
#choleradata$weeknum <- format(choleradata$Date, format = "%y-%W")
#identify new cases
#cd <- transmute(choleradata, weeknum, Date, Cases)
#cd <- cd %>%
#  arrange(Date) %>%
#  mutate(newcases = Cases - lag(Cases, default=0))
#cdx <- as.data.frame(xtabs(newcases ~ weeknum, data = cd))
#ggplot(cdx, aes(x= weeknum, y = Freq)) + geom_col() + scale_y_continuous(limits = c(0, 60000))
# No idea why this is. Code is left in here to prove I can do it, I guess. 

# I ended up using WebPlotDigitizer and a screen capture of the WHO's reported epi curve from 2018 week 2. ----
choleradata <- read.csv("Extracted Yemen EpiCurve.csv")
choleradata <- transmute(choleradata, Date = choleradata$X2016.10.09, Cases = round(choleradata$X330.18867924528604))
choleradata <- slice(choleradata, 27:66) # only want relevant portions of this graph
ggplot(choleradata, aes(x= Date, y = Cases)) + geom_point()

## prior function  ----

# The following are from Fung et al's estimated parameters
#contactRate = range from 0.00001 to 1 (contact rate to dirty water per day)
#contamRate = contamination of water (cells per ml per person per day) range: 0.01 - 10
#cleanRate = cholera's life span in days - range: 3-41
          
logPrior <- function(theta) {
  # Prior on contactRate - going to assume this one is a uniform distribution:
  logPriorcontactRate <- dunif(theta[["contactRate"]], min = 0.00001, max = 1, log = TRUE)
  # Prior on contamination rate: 
  logPriorcontamRate <- dunif(theta[["contamRate"]], min = 0.01, max = 10, log = TRUE)
  # Prior on cleaning rate - numbers from Felsenfeld (referenced in Fung paper)
  logPriorcleanRate <- dnorm(theta[["cleanRate"]], mean = 19.3, sd = 5.1, log = TRUE)
  
  return(logPriorcontactRate + logPriorcontamRate + logPriorcleanRate)
}

pointLogLike <- function(i, PrevData, PrevModel) {
  # Prevalence is observed through a Poisson process.
  return( dpois(x=PrevData[i], lambda=PrevModel[i], log=TRUE) )
}

## Likelihood function for all data points:
trajLogLike <- function(time, PrevData, theta, initState) {
  traj <- data.frame(ode(y=initState, times=time, func=cholera, 
                         parms=theta, method = "ode45"))
  PrevModel <- traj$I
  logLike <- 0
  for (i in 1:length(time)) {
    logLike <- logLike + pointLogLike(i, PrevData, PrevModel)
  }
  return(logLike)
}




inf <- ode(y = c(S = 30000000, I = 1, R = 0, B = 0),
           times = 1:365,
           parms = theta,
           func = cholera)
inf_df <- data.frame(inf)
plot(x = inf_df$time, y = inf_df$I)
ggplot(inf_df, aes(x = time, y = I)) + geom_point()
