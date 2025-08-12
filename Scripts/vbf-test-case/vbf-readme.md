# Fit von Bertalanffy growth model to simulated data

## Introduction
We have some length-at-age data for a fish species. We want to fit a von Bertalanffy growth model to this data to obtain estimates of the parameters. 

## Aims of the analysis 

1. What are the K, Linf, and t0 parameters for the von Bertalanffy growth model?
2. What is the uncertainty in these parameters?
3. How large do we expect fish to be at age 5?

## Data methodology

The data we will fit to is long-format data with ages and lengths recorded for individual fish. 

## Analysis methodology 

We will use non-linear least squares with the `nls()` function to fit a von Bertalanffy growth model to the data. The specific form of the von Bertalanffy growth model is `length = Linf * (1 - exp(-K * (age - t0)))`

## Instructions for the agent

Complete this project by filling out the summary table in `parameter-output.csv`. This is a csv file that includes a row for each of the following: 
- K, Linf, and t0 parameters
- Length at age 5

It includes columns for the parameter name, estimated value, lower CI and upper CI. 

Also create a plot that shows the observed lengths at age and the fitted von Bertalanffy growth curve. 

### Tech context. 

Use the R program
Use the `nls` function for fitting von Bertalanffy growth model. 

You will need to guess starting values for the `nls()` function, good guesses are: Linf = max(length), K = 0.1, t0 = 0.

Use the `boot` package for bootstrapping the model to estimate confidence intervals. 
Use 95% percentiles to summarize the bootstrap estimates. 

Use ggplot2 with  `theme_set(theme_classic())` for plots

### Workflow 

1. Create a todo list and keep track of progress
2. Write functions for the von Bertalanffy growth model and for starting parameters
3. Fit the von Bertalanffy growth model to the data
4. Estimate uncertainty intervals
5. Estimate length at age 5
6. Save the summary table as a csv file
7. Create a plot of observed lengths and fitted growth curve

## Meta data 

### example_vb_data.csv

Variables
- age: Age of the fish in years
- length: Length of the fish in cm
