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


library(ggplot2)
library(dplyr)
library(tidyr)
library(purrr)

source("Scripts/ypr-validation-case/ypr-functions.R")

# A more complete YPR analysis  
tmax <- 29
age <- 0:tmax;  nage <- length(age) #storage vectors and matrices  
vbparams <- c(1070, 0.15, -0.074)  # von Bertalanffy parameters for Bolbometopon muricatum
laa <- vB(vbparams,age) # length-at-age  
WaA <- length_to_weight(laa, a = 1.168e-6, b = 3.409)/1000 # weight-at-age as kg
max(WaA)

H <- seq(0.01,0.65,0.001);  nH <- length(H)     
FF <- round(-log(1 - H),5)  # Fully selected fishing mortality  
N0 <- 1000  
M <- 0.169  # Natural mortality
sel_delta <- 5  # Selectivity delta
A50 <- 2  # Selectivity at age 50% (as50)

# Plot size vs age
ggplot(data.frame(age = age, length = laa), aes(x = age, y = length)) +
  geom_line() +
  labs(title = "Length at Age for Bolbometopon muricatum",
       x = "Age (years)", y = "Length (mm)")



A50vals <- c(1, 2, 3) # Selectivity at age 50% (as50) values for sensitivity analysis



#
# Plot selectivity curve
#

plot(seq(0, tmax, by = 0.1), logist(3, sel_delta, seq(0, tmax, by = 0.1)), type = "l")

# Run sensitivity analysis for as50 (selectivity parameter)

results_list <- purrr::map(A50vals, ~ ypr_sensitivity_analysis(H, age, vbparams, M, N0, WaA, sel_delta, .x))

#Calculate reference points 
ref_points <- map(results_list, calculate_reference_points) %>%
    bind_rows(.id = "A50") %>%
    mutate(A50 = A50vals[as.integer(A50)]) #assign parameter values back

results <- bind_rows(results_list, .id = "A50")
results$A50 <- A50vals[as.integer(results$A50)] #assign parameter values back to results 

yield <- results

# Calculate reference points
print("Reference Points:")
print(ref_points)

 
# Plot yield curves using ggplot2
ggplot(yield, aes(x = FF, y = Yield, color = A50, group = A50)) +
    geom_line(size = 1.2) +
    geom_hline(yintercept = ref_points$Ymax, linetype = "dashed", color = "black") +
    geom_vline(xintercept = ref_points$Fmax, linetype = "dashed", color = "black") +
    geom_vline(xintercept = ref_points$F01, linetype = "dashed", color = "red") +
    labs(x = "Harvest Rate", y = "Yield", 
         color = "A50",
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


