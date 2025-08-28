# Fit von Bertalanffy growth model to simulated data

## Introduction
We have some length-at-age data for a fish species. We want to fit a von Bertalanffy growth model to this data to obtain estimates of the parameters. 

## Aims of the analysis 

1. What are the K, Linf, and t0 parameters for the von Bertalanffy growth model?
2. What is the uncertainty in these parameters?
3. How large do we expect fish to be at age 5?

## Data methodology

The data we will fit to is long-format data with ages and lengths recorded for individual fish. 

## Instructions for the agent

Complete this project by filling out the summary table in `parameter-output.csv`. This is a csv file that includes a row for each of the following: 
- K, Linf, and t0 parameters
- Length at age 5

It includes columns for the parameter name, estimated value, lower CI and upper CI. 

Also create a plot that shows the observed lengths at age and the fitted von Bertalanffy growth curve. 

### Tech context. 

Use the R program to fit a von Bertalanffy curve to the data. Estimate the mean and the 95% confidence intervals for the parameters. 

Use ggplot2 with  `theme_set(theme_classic())` for plots

## Meta data 

### example_vb_data.csv

Variables
- age: Age of the fish in years
- length: Length of the fish in cm
