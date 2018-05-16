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
setwd("~/GitHub/2017-Cholera-in-Yemen/ODE")
library(deSolve)
cholera <- function(time, state, parameters) {
  ## parameters
  rec <- 1 / parameters["infectiousPeriod"]
  mu <- parameters["deathRate"]
  xi <- parameters["contamRate"]
  del <- parameters["cleanRate"]
  beta <- parameters["contactRate"]
  chi <- parameters["chi"]
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

inf <- ode(y = c(S = 30000000, I = 1, R = 0, B = 0),
                  times = 1:365,
                  parms = c(contactRate = .08,  # will need to use fitting techniques to figure this out from data. 
                                                # range from 0.00001 to 1 (contact rate to dirty water per day)
                            infectiousPeriod = 5, # from Fung et al. range is 2.9 - 14. 
                            deathRate = 0.002, # calculated from the death rate of the yemen outbreak
                            contamRate = 2, # will need to be fitted. 
                                            # contamination of water (cells per ml per person per day) range: 0.01 - 10
                            cleanRate = 15, # will need to be fitted. 
                                          # cholera's life span in days - range: 3-41
                            chi = 1000000 # concentration that yields 50% chance of infection. from Fung et al
                            ),
                  func = cholera)

inf_df <- data.frame(inf)
plot(x = inf_df$time, y = inf_df$I)



# References: 
# 1) https://ete-online.biomedcentral.com/articles/10.1186/1742-7622-11-1
# 2) https://tbiomed.biomedcentral.com/articles/10.1186/s12976-017-0061-x
