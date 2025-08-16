# YPR model 
# Set-up for agent questions
# CJ Brown 2025-08-16
# Example and functions taken from: https://haddonm.github.io/URMQMF/simple-population-models.html#full-yield-per-recruit
#
# Bolbo growth parameters
# Linf: 1070mm
# K: 0.15
# t0: -0.074
# M: 0.169
# Length-weight: a: 1.168*10^(-6), b: 3.409

# UP TO here, keep tidying up so I can build the YPR test-case spec
# Get it to calculate F0.1 
# get it to calculate max yield for different size limits 
# Git it to look at sensitivity of F0.1 to M 


library(ggplot2)
library(dplyr)
library(tidyr)

## Function for von Bertalanffy growth equation
vB <- function(pars, age) {
   # pars: vector of parameters c(Linf, k, t0)
   Linf <- pars[1]
   k <- pars[2]
   t0 <- pars[3]
   Linf * (1 - exp(-k * (age - t0)))
}

## Function for length to weight conversion
length_to_weight <- function(length, a = 0.015, b = 3.0) {
   # length in cm, returns weight in grams
   a * length^b
}

## Function for logistic selectivity
logist <- function(inL50, delta, depend) {
  1/(1 + exp(-log(19) * (depend - inL50)/(delta)))
}

## Function for Baranov catch equation
bce <- function(M, Fat, Nt, ages) {
    nage <- length(ages)
    lFat <- length(Fat)

    Z <- (M + Fat)
    columns <- c("Nt", "N-Dying", "Catch")
    ans <- matrix(0, nrow = nage, ncol = length(columns), dimnames = list(ages, 
        columns))
    ans[1, ] <- c(Nt, NA, NA)
    for (a in 2:nage) {
        Na <- ans[(a - 1), "Nt"]
        newN <- Na * exp(-Z[a])
        catch <- (Fat[a]/(M + Fat[a])) * Na * (1 - exp(-(Z[a])))
        mort <- Na - (newN + catch)
        ans[a, ] <- c(newN, mort, catch)
    }
    return(ans)
}

# Calculate reference points for each selectivity scenario
calculate_reference_points <- function(yield_data) {
# Reference points 
# Fmax: the fishing mortality rate which produces the maximum yield per recruit.
# F0.1: the fishing mortality rate corresponding to 10% of the slope of the yield-per-recruit curve at the origin. 
  ref_points <- yield_data %>%
    group_by(parameter_value) %>%
    arrange(FF) %>%
    summarise(
      Fmax = FF[which.max(Yield)],
      Ymax = max(Yield),
      # F0.1 approximation (fishing mortality at 10% of initial slope)
      initial_slope = (Yield[2] - Yield[1]) / (FF[2] - FF[1]),
      target_slope = 0.1 * initial_slope,
      .groups = "drop"
    )
  
    # Calculate F0.1
    ref_points <- yield_data %>%
        # Calculate slope of the yield curve 
        group_by(parameter_value) %>%
        arrange(FF) %>%

        left_join(ref_points) %>%
     group_by(parameter_value) %>%
     mutate(F01 = {
      # Find the index where the slope is closest to 10%
      idx <- which(abs(diff(Yield) / diff(FF) - target_slope) == min(abs(diff(Yield) / diff(FF) - target_slope)))
      if (length(idx) > 0) {
        FF[idx[1]]
      } else {
        NA
      }
        }) %>%
     mutate(Yield_at_F01 = Yield[which(FF == F01)])
     ungroup() %>%
     select(parameter_value, Fmax, Ymax, F0.1)   

    
  return(ref_points)
}

# A more complete YPR analysis  
tmax <- 29
age <- 0:tmax;  nage <- length(age) #storage vectors and matrices  
vbparams <- c(1070, 0.15, -0.074)  # von Bertalanffy parameters for Bolbometopon muricatum
laa <- vB(vbparams,age) # length-at-age  
WaA <- length_to_weight(laa, a = 1.168e-6, b = 3.409)/1000 # weight-at-age as kg
max(WaA)

H <- seq(0.01,0.65,0.01);  nH <- length(H)     
FF <- round(-log(1 - H),5)  # Fully selected fishing mortality  
N0 <- 1000  
M <- 0.169  # Natural mortality

## Function for YPR sensitivity analysis
ypr_sensitivity_analysis <- function(param_values, param_name, H, age, vbparams, M, N0, WaA,sel_func = logist, sel_delta = 1.0, as50_base = 2, ...) {
  
  FF <- round(-log(1 - H), 5)  # Fully selected fishing mortality
  nH <- length(H)
  nage <- length(age)
  
  # Storage matrices
  numt <- matrix(0, nrow = nage, ncol = nH, dimnames = list(age, FF))
  catchN <- matrix(0, nrow = nage, ncol = nH, dimnames = list(age, FF))
  
  # Initialize result storage
  yield_results <- NULL
  selectivity_curves <- NULL
  
  for (i in seq_along(param_values)) {
    param_val <- param_values[i]
    
    # Calculate selectivity-at-age and other parameters based on what's being varied
    if (param_name == "as50") {
      sa <- sel_func(param_val, sel_delta, age)
      M_current <- M
    } else if (param_name == "M") {
      sa <- sel_func(as50_base, sel_delta, age)
      M_current <- param_val
    } else if (param_name == "sel_delta") {
      sa <- sel_func(as50_base, param_val, age)
      M_current <- M
    } else {
      warning(paste("Parameter", param_name, "not implemented. Using as50."))
      sa <- sel_func(param_val, sel_delta, age)
      M_current <- M
    }
    
    # Store selectivity curves
    selectivity_curves <- rbind(selectivity_curves, 
                               data.frame(age = age, 
                                        selectivity = sa, 
                                        parameter_value = param_val,
                                        parameter_name = param_name))
    
    # Calculate yield for each harvest rate
    yield_temp <- rep(0, nH)
    
    for (harv in seq_along(H)) {
      Ft <- sa * FF[harv]  # Fishing mortality-at-age
      out <- bce(M_current, Ft, N0, age)
      numt[, harv] <- out[, "Nt"]
      catchN[, harv] <- out[, "Catch"]
      yield_temp[harv] <- sum(out[, "Catch"] * WaA, na.rm = TRUE)
    }
    
    # Store yield results
    yield_results <- rbind(yield_results, 
                          data.frame(H = H,
                                   FF = FF,
                                   Yield = yield_temp,
                                   parameter_value = param_val,
                                   parameter_name = param_name))
  }
  
  return(list(yield_data = yield_results, 
              selectivity_data = selectivity_curves))
}

# Run sensitivity analysis for as50 (selectivity parameter)
as50_values <- c(1, 2, 3)
results <- ypr_sensitivity_analysis(param_values = as50_values,
                                   param_name = "as50",
                                   H = H,
                                   age = age,
                                   vbparams = vbparams,
                                   M = M,
                                   N0 = N0,
                                   WaA = WaA)

# Extract results
yield <- results$yield_data
sel_curves <- results$selectivity_data  



# Calculate reference points
ref_points <- calculate_reference_points(yield)
print("Reference Points:")
print(ref_points)

 
# Plot yield curves using ggplot2
ggplot(yield, aes(x = H, y = Yield, color = factor(parameter_value), linetype = factor(parameter_value))) +
    geom_line(size = 1.2) +
    geom_hline(yintercept = ref_points$Ymax, linetype = "dashed", color = "black") +
    geom_vline(xintercept = ref_points$Fmax, linetype = "dashed", color = "black") +
    labs(x = "Harvest Rate", y = "Yield", 
         color = "as50", linetype = "as50",
         title = "Yield per Recruit vs Harvest Rate") +
    theme_classic() + 
    theme(legend.position = "bottom")


# Plot selectivity curves 
ggplot(sel_curves, aes(x = age, y = selectivity, color = factor(parameter_value))) +
    geom_line(size = 1.2) +
    labs(x = "Age", y = "Selectivity", 
         color = "as50",
         title = "Selectivity Curves by Age") +
    scale_color_manual(values = c("red", "blue", "green")) +
    theme_minimal() +
    theme(legend.position = "bottom")




# Example: Additional sensitivity analyses using the new function

# Sensitivity analysis for different natural mortality rates
# M_values <- c(0.1, 0.169, 0.25)
# M_results <- ypr_sensitivity_analysis(param_values = M_values,
#                                      param_name = "M", 
#                                      H = H, age = age, vbparams = vbparams,
#                                      M = M, N0 = N0, WaA = WaA)

# Sensitivity analysis for different selectivity delta values
# delta_values <- c(0.5, 1.0, 2.0)
# delta_results <- ypr_sensitivity_analysis(param_values = delta_values,
#                                          param_name = "sel_delta",
#                                          H = H, age = age, vbparams = vbparams,
#                                          M = M, N0 = N0, WaA = WaA)


