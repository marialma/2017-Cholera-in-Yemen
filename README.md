# 2017-Cholera-in-Yemen

[Back to the portfolio page...](https://marialma.github.io/)

Pulling data from the [Humanitarian Data Exchange](https://data.humdata.org/dataset/yemen-cholera-outbreak-daily-epidemiology-update) in an effort to learn a bit more about the cholera outbreak in Yemen. I am also using a dataset from the [Yemen Data Project](http://yemendataproject.org). I'm using this as a chance to learn and exercise some skills. 

The current plan is to shape data using R, then using Bokeh in Python to display it. 

## Initial Results
As of 2017-09-11, my cholera dataset is behind by about 3 weeks. Additionally, the cholera datast starts at the end of May 2017, and the Yemen Data Project dataset ends in March 2017. The code is mostly ready to be run, but I think I'm going to have to wait for that data. 

The cholera epidemic is likely several months in the making before the first couple cases. It takes some pretty serious infrastructure damage to get cholera cases, and more damage to get them to spread. Initially, I was hoping to show a correlation between locations that were heavily bombed, and where the initial cases of cholera were being seen. 

Unfortunately, this correlation was poor - showing pretty much no correlation. This could be explained in several ways - possibly migration, or data loss. 
* Heavily bombed areas just had a lot of people move away. 
* People dying from cholera just aren't being counted, as there's nowhere to count them
* Lack of good reporting infrastructure, especially in the first couple days of a declared epidemic. 

It's kind of hard to say. Additionally, the time lag for the data makes any relationship I pull out of it to be kind of a stretch. I will look again and put the graphs/ stats-y things up when I get an updated data set. 