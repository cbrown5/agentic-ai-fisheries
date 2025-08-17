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
A50 <- 5  # Selectivity at age 50% (as50)

# Plot size vs age
ggplot(data.frame(age = age, length = laa), aes(x = age, y = length)) +
  geom_line() +
  labs(title = "Length at Age for Bolbometopon muricatum",
       x = "Age (years)", y = "Length (mm)")

#Calculate age at sizes of 400, 500 and 600mm
size_limit <- c(400, 500, 600)
A50vals <- vB_inverted(vbparams,size_limit)
slimdat <- data.frame(A50 = A50vals, size_limit = size_limit)
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

# Create a summary table that includes the reference points for each size limit
summary_table <- ref_points %>%
    select(A50,Fmax, Ymax, F01) %>%
    left_join(slimdat, by = "A50") %>%
    pivot_longer(cols = -c(A50, size_limit), names_to = "Reference Point", values_to = "Value") %>%
    mutate(`Reference Point` = factor(`Reference Point`, levels = c("Fmax", "Ymax", "F01")))  %>%
    select(size_limit, ref_point = `Reference Point`, A50, value = Value)

write.csv(summary_table, "Scripts/ypr-validation-case/ypr_reference_points.csv", row.names = FALSE)
