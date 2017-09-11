# To Do:

* Re-process ydp.csv 
* Look at correlations between places that were bombed over the last two years and how bad cholera is
  * attack rate vs CFR vs total numbers?
  * regression?
* Time series data here is going to be useful - but how?
* Python 
* Update datasets 


## 2017-09-11

Initial corr() of hospitals getting bombed with what the epidemic looked like on day 1 of WHO data shows a *negative* correlation (-0.12). But the initial thought was flawed to begin with - a hospital being there shouldn't necessarily have to do wtih the attack rate - it may have more to do with case fatality rate.In any case, the dataset would not control for number of hospitals in a region to begin with, so this may be less useful until later. 

Instead, I will look at overall total # of bombings in a region and look at its relationship to attack rates and case fatality rates

