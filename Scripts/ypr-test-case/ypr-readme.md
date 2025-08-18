# Yield per recruit analysis for Bolbometopon muricatum

## Introduction
This project will analyze the yield per recruit (YPR) for *Bolbometopon muricatum*, the bumphead parrotfish. We will calculate fisheries reference points for different size limits to inform sustainable fishing practices. 

## Aims of the analysis

1. Calculate yield per recruit curves for four scenarios: a base case with no size limits and three size limits (400, 500, and 600 mm). 
2. Determine fisheries reference points: Fmax, Ymax, and F01 for each scenarios. 
3. Plot the yield curves (harvest rate vs yield) for each scenario. 

## Biological and fisheries parameters

The analysis will use the following biological parameters for *Bolbometopon muricatum*:

### Growth parameters (von Bertalanffy growth equation)
- **Linf**: 1070 mm (asymptotic length)
- **K**: 0.15 per year (growth coefficient)
- **t0**: -0.074 years (theoretical age at length zero)

### Mortality and other parameters
- **M**: 0.169 per year (instantaneous natural mortality rate)
- **Maximum age**: 29 years
- **Initial recruitment**: 1000 individuals (per recruit analysis)

### Length-weight relationship parameters
- **a**: 1.168 × 10^(-6) (length-weight coefficient)
- **b**: 3.409 (length-weight exponent)
- Note: Length in mm, weight in grams, convert to kg for yield calculations

### Selectivity parameters
- **delta**: 0.001 (selectivity slope parameter)
- **A50**: Age at 50% selectivity (calculated based on size limits). For the base case this is 3 years. For the size limit scenarios the A50 values will need to be calculated from the inverse von Bertalanffy growth equation.

## Reference points 

- **Ymax**: Maximum yield per recruit for a scenario
- **Fmax**: Fishing mortality rate (instantaneous) that produces Ymax for each scenario
- **F01**: Fishing mortality rate (instantaneous) where the slope of the yield curve equals 10% of the slope at the origin (a more conservative reference point than Fmax)

## Analysis methodology

We will use yield per recruit (YPR) analysis to evaluate the effects of different fishing mortalities and size limits on the potential yield from this fishery. The steps are: 

1. **Growth modeling**: Calculate length-at-age using the von Bertalanffy growth equation
2. **Weight conversion**: Convert length-at-age to weight-at-age using allometric relationships
3. **Calculate A50 values**: For each size limit, calculate the age at 50% selectivity using the inverse von Bertalanffy equation
4. **Selectivity modeling**: Model how fishing selectivity changes with age based for each scenario. 
4. **Population modeling**: Use the Baranov catch equation to model fishing and natural mortality
5. **Yield calculation**: Calculate yield per recruit across a range of fishing mortalities
6. **Reference point estimation**: Determine Fmax, Ymax, and F01 from yield curves

### Key equations (provide as R functions)

#### Von Bertalanffy growth equation
```r
Linf * (1 - exp(-k * (age - t0)))
```

#### Inverse von Bertalanffy (age at length)
```r
(log(1 - length / Linf) / -k) + t0
```

#### Length to weight conversion
Note, length in mm, returns weight in grams
```
a * length^b
```

#### Logistic selectivity function
```
1/(1 + exp(-log(19) * (A - A50)/(delta)))
```
Note that `A50` is the age at 50% selectivity, and `delta` controls the slope of the selectivity curve. For a size limit you should set `A50` to the age at which fish reach that size limit and `delta` to a small value (e.g. 0.001) to get a steep selectivity curve.


#### Population dynamics

```r
Z <- M + Fat  # Total mortality at age
Na <- Nt * exp(-Z)  # Number of fish at age after mortality
``` 

Note there is no mortality at age 0, so the first age class is not included in the calculations. 

#### Baranov catch equation
```r
(Fat[a]/(M + Fat[a])) * Na * (1 - exp(-(Z[a])))
```
Where: 
- `Fat[a]` is the fishing mortality at age `a`
- `Na` is the number of fish at age `a`
- `Z[a]` is the total mortality at age `a` (natural + fishing)

## Instructions for the agent

### Goals 

Fill out the reference point values in `ypr_reference_points.csv` with the calculated Fmax, Ymax, and F01 values for each of the three size limits (400, 500, and 600 mm) and the baseline scenario with no size limit.

Create a plot showing the yield curves (yield against fishing mortality) for all four scenarios. 

### Tech context
- Use R programming language
- tidyverse packages for data manipulation
- ggplot2 for data visualization  
- Use `theme_set(theme_bw())` for plots
- purrr package for functional programming (map functions)

Keep scripts modular and save intermediate results. Create separate scripts for different analysis phases.

### Directory structure

```
ypr-test-case/
├── data/                    # Processed data files (if any intermediate datasets)
├── outputs/                 # Generated output files
│   └── plots/              # Yield curve plots and visualizations (PNG files)
├── scripts/                # R scripts for YPR analysis
├── ypr_reference_points.csv # Template file where the agent should fill in the calculated values
└── ypr-readme.md           # This documentation file
```

### Expected outputs

1. **Completed CSV file**: `ypr_reference_points.csv` with all reference point values filled in
2. **Yield curve plots**: Showing yield vs fishing mortality for all size limits



