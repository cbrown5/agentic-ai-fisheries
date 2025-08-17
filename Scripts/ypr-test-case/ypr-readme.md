# Yield per recruit analysis for Bolbometopon muricatum

## Introduction
This project will analyze the yield per recruit (YPR) for *Bolbometopon muricatum*, the bumphead parrotfish. We will calculate fisheries reference points for different size limits to inform sustainable fishing practices. The bumphead parrotfish is a critically important species in coral reef ecosystems and is vulnerable to overfishing due to its large size and slow growth.

## Aims of the analysis

1. Calculate yield per recruit curves for three different size limits (400, 500, and 600 mm) and a base case with no size limit. 
2. Determine fisheries reference points: Fmax, Ymax, and F01 for each size limit and the base case 
3. Plot the yield curves (harvest rate vs yield) for each size limit. 

## Biological and fisheries parameters

The analysis will use the following biological parameters for *Bolbometopon muricatum*:

### Growth parameters (von Bertalanffy growth equation)
- **Linf**: 1070 mm (asymptotic length)
- **K**: 0.15 per year (growth coefficient)
- **t0**: -0.074 years (theoretical age at length zero)

### Mortality and other parameters
- **M**: 0.169 per year (natural mortality rate)
- **Maximum age**: 29 years
- **Initial recruitment**: 1000 individuals (per recruit analysis)

### Length-weight relationship parameters
- **a**: 1.168 × 10^(-6) (length-weight coefficient)
- **b**: 3.409 (length-weight exponent)
- Note: Length in mm, weight in grams, convert to kg for yield calculations

### Selectivity parameters
- **sel_delta**: 5 (selectivity slope parameter)
- **Size limits**: 400, 500, and 600 mm (corresponding to different A50 values)

## Analysis methodology

We will use yield per recruit (YPR) analysis to evaluate the effects of different fishing mortalities and size limits on the potential yield from this fishery. The analysis involves several key steps:

1. **Growth modeling**: Calculate length-at-age using the von Bertalanffy growth equation
2. **Weight conversion**: Convert length-at-age to weight-at-age using allometric relationships
3. **Selectivity modeling**: Model how fishing selectivity changes with age based on size limits
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
Note that `A50` is the age at 50% selectivity, and `delta` controls the slope of the selectivity curve. For a size limit you should set `A50` to the age at which fish reach that size limit and `sel_delta` to a small value (e.g. 0.001) to get a steep selectivity curve.

#### Baranov catch equation
```r
(Fat[a]/(M + Fat[a])) * Na * (1 - exp(-(Z[a])))
```
Where: 
- `Fat[a]` is the fishing mortality at age `a`
- `Na` is the number of fish at age `a`
- `Z[a]` is the total mortality at age `a` (natural + fishing)

### Reference points definitions

- **Fmax**: The fishing mortality rate that produces the maximum yield per recruit
- **Ymax**: The maximum yield per recruit (corresponding to Fmax)
- **F01**: The fishing mortality rate where the slope of the yield-per-recruit curve equals 10% of the slope at the origin (a more conservative reference point)

## Analysis workflow

### Age and size structure setup
- Create age vector from 0 to maximum age
- Calculate length-at-age using von Bertalanffy parameters
- Convert length-at-age to weight-at-age (in kg for yield calculations)
- Calculate A50 values (age at 50% selectivity) for each size limit using the inverse von Bertalanffy equation 

### Harvest rate scenarios
- Create a sequence of harvest rates from 0.01 to 0.65 (increment by 0.001)
- Convert harvest rates to fishing mortality: FF = -log(1 - H)

### Yield per recruit calculation
For each size limit and harvest rate:
1. Calculate selectivity-at-age using the logistic function
2. Calculate fishing mortality-at-age (selectivity × fully-selected fishing mortality)
3. Use Baranov catch equation to calculate catch-at-age
4. Calculate total yield by summing catch-at-age × weight-at-age

### Reference point calculation
For each size limit:
1. Find Fmax as the fishing mortality that maximizes yield
2. Record Ymax as the maximum yield value
3. Calculate F01 by finding where the slope equals 10% of the initial slope

## Instructions for the agent

The agent will complete a yield per recruit analysis and fill in the reference points table. The analysis should produce:

1. **Data processing**: Set up age structure, growth, and weight data
2. **YPR calculations**: Calculate yield curves for all three size limits
3. **Reference point estimation**: Calculate Fmax, Ymax, and F01 for each scenario
4. **Results output**: Fill in the `ypr_reference_points.csv` file with calculated values
5. **Visualization**: Create plots showing yield curves and reference points
6. **Summary report**: Write a brief markdown report with key findings

### Tech context
- Use R programming language
- tidyverse packages for data manipulation
- ggplot2 for data visualization  
- Use `theme_set(theme_classic())` for plots
- purrr package for functional programming (map functions)

Keep scripts modular and save intermediate results. Create separate scripts for different analysis phases.

### Workflow steps

1. **Setup and parameters**: Create age structure and biological parameters
2. **Growth and weight calculations**: Calculate length-at-age and weight-at-age
3. **Selectivity calculations**: Calculate A50 values for each size limit
4. **YPR analysis**: Run yield per recruit calculations for all scenarios
5. **Reference point calculation**: Extract Fmax, Ymax, and F01 values
6. **Results export**: Fill in the CSV file with calculated reference points
7. **Visualization**: Create yield curve plots with reference points marked
8. **Report generation**: Summarize findings and recommendations

### Directory structure

```
ypr-test-case/
├── data/                    # Processed data files (if any intermediate datasets)
├── outputs/                 # Generated output files
│   └── plots/              # Yield curve plots and visualizations (PNG files)
├── scripts/                # R scripts for YPR analysis
├── ypr_reference_points.csv # Template file to fill with calculated values
└── ypr-readme.md           # This documentation file
```

### Expected outputs

1. **Completed CSV file**: `ypr_reference_points.csv` with all reference point values filled in
2. **Yield curve plots**: Showing yield vs fishing mortality for all size limits
3. **Reference point visualization**: Plots marking Fmax and F01 on yield curves
4. **Summary statistics**: Table comparing reference points across size limits
5. **Brief analysis report**: Markdown file with key findings and management recommendations

### Quality checks

- Verify that Fmax values are reasonable (typically between 0.1 and 1.0)
- Ensure F01 < Fmax for all scenarios (F01 should be more conservative)
- Check that larger size limits generally result in higher A50 values
- Validate that yield curves show expected dome shape

GOAL: Fill out the reference point values in `ypr_reference_points.csv` with the calculated Fmax, Ymax, and F01 values for each of the three size limits (400, 500, and 600 mm).


