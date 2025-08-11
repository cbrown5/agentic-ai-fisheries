# GLM Validation Case Rubric

## Project Structure 

**Directory structure created correctly?** 
- 0: No proper directory structure
- 1: Some files in correct locations but not fully structured
- 2: Correct directory structure with data/, outputs/plots/, scripts/ folders

**Files saved in correct locations?** 
- 0: Files not in specified locations
- 1: Files mostly saved in correct locations
- 2: All files saved according to specified directory structure

## Data Processing

**Calculate % cover correctly?** 
- 0: Did not calculate percent cover
- 1: Incorrectly calculated percent cover
- 2: Correctly divided CB_cover and soft_cover by n_pts to get percent cover

**Data loaded and processed modularly?** 
- 0: All processing in one script or not modular
- 1: Some modularity but not fully separated
- 2: Data processing done in separate, modular script

## Model Selection and Fitting

**Used correct model family?**
- 0: Did not use negative binomial GLM
- 1: Used other GLM family
- 2: Used MASS::glm.nb() correctly

**Fitted full interaction model?** 
- 0: Did not fit interaction model
- 1: Correctly fitted pres.topa ~ CB_cover*soft_cover model

**Performed likelihood ratio tests?** 
- 0: No LR tests performed
- 1: Some LR tests performed but incomplete
- 2: Completed LR test sequence for model selection

**p-values from LR tests?** 
- 0: P-values not reported
- 1: P-values reported

**p-values accurate?**
- 0: P-values not accurate
- 1: Concluded interaction term significant but not based on LR test
- 2: P-value on the interaction accurate and based on LR tests (p = )

## Model Verification 

**Produced diagnostic plots?** 
- 0: No diagnostic plots
- 2: Some diagnostic plots produced
- 3: Complete set of diagnostic plots (residuals vs fitted, Q-Q plot, Cook's distance, distribution of counts and predicted counts or rootograms)

**Saved diagnostic plots as PNG files?** 
- 0: Plots not saved as PNG
- 1: Diagnostic plots correctly saved as PNG files

**Correct interpretation of diagnostics?**
- 0: No interpretation of diagnostics
- 1: Basic interpretation provided
- 2: Good interpretation with some technical understanding
- 3: Comprehensive interpretation with correct technical assessment

## Model Predictions and Visualization

**Created prediction plots?**
- 0: No prediction plots created
- 1: Prediction plots created using visreg or equivalent

**Used correct scale for predictive plots?**
- 0: Used incorrect scale (response scale)
- 1: Used appropriate scale (log/linear scale) for interpretation

**Included confidence intervals?**
- 0: No confidence intervals shown
- 1: 95% confidence intervals included in plots

## Reporting and Documentation

**Produced markdown report?**
- 0: No markdown report produced
- 1: Main analysis report produced in markdown or rmarkdown format

**Produced diagnostic report?** 
- 0: No separate diagnostic report
- 1: Separate diagnostic markdown report for model diagnostics

**Main report knits successfully?** 
- 0: Report does not knit or has errors
- 1: Report knits without errors

**Diagnostic report knits successfully?** 
- 0: Diagnostic report does not knit or has errors
- 1: Diagnostic report knits without errors

## Content Quality and Completeness

**Answered all study aims?** 
- 0: Did not address study aims
- 1: Partially addressed study aims
- 2: Clearly addressed all 4 study aims from introduction

**Included required report sections?**
- 0: Missing multiple required sections
- 1: Missing 1-2 required sections
- 2: All required sections present (Study aims, Data methodology, Analysis methodology, Results)

**Correct interpretation of results?**
- 0: No interpretation or completely incorrect
- 25: Basic interpretation with major errors
- 50: Adequate interpretation with some errors
- 75: Good interpretation with minor errors
- 100: Excellent interpretation, technically correct and well-explained

## Technical Implementation

**Used modular scripts?**
- 0: Everything in one script
- 1: Analysis broken into logical, modular scripts


## Bonus Points (5 points)

**Innovation or additional insights?**
- 0: No additional insights
- 1: Provided additional useful analysis or insights beyond requirements

**Identified confounding between CB_cover and soft_cover?**
- 0: Did not identify confounding
- 1: Identified confounding but did not address it
- 2: Identified and addressed confounding in analysis or reporting

---
