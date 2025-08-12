# Fit von Bertalanffy growth model to simulated data

## Introduction
We have some length-at-age data for a fish species. We want to fit a von Bertalanffy growth model to this data to obtain estimates of the parameters. 

## Aims of the analysis 

1. What are the K, Linf, and t0 parameters for the von Bertalanffy growth model?
2. What is the uncertainty in these parameters?
3. How large do we expect fish to be at age 5?

## Data methodology

The data is long-format data with ages and lengths recorded for individual fish. 

## Analysis methodology 

We will use non-linear least squares with the `nls()` function to fit a von Bertalanffy growth model to the data. 

## Instructions for the agent

Create a summary table as a csv file that includes a row for each of the following: 
- K, Linf, and t0 parameters
- Length at age 5

Includes columns for the parameter name, estimated value, lower CI and upper CI. I have included a template in `parameter-output.csv`.

Also create a plot that shows the observed lengths at age and the fitted von Bertalanffy growth curve. 


### Tech context
- We will use the R program
- Use `nls` fitting the von Bertalanffy growth model
- Use the `car` package for bootstrapping the model to estimate confidence intervals
- ggplot2 with  `theme_set(theme_classic())` for plots

Here is how to fit the model with the `FSA` package:

```r
library(FSA)
vb <- makeGrowthFun(type = "von Bertalanffy")
param_start <- findGrowthStarts(length~age,data=dat)
f.fit <- nls(length~vb(age,Linf,K,t0),data=dat,param_start)
f.fit
```

You can use the `car` package to estimate the confidence intervals: 

```r
library(car)
f.boot1 <- Boot(f.fit)
confint(f.boot1, type = "perc")
```



### Workflow 

1. Create a todo list and keep track of progress
2. Fit the von Bertalanffy growth model to the data
3. Estimate uncertainty intervals
4. Estimate length at age 5
5. Save the summary table as a csv file
6. Create a plot of observed lengths and fitted growth curve

## Meta data 

### example_vb_data.csv

Variables
- age: Age of the fish in years
- length: Length of the fish in cm
