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

rm(list = ls())
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
A50 <- 5  # Selectivity at age 50% (as50)

# Plot size vs age
ggplot(data.frame(age = age, length = laa), aes(x = age, y = length)) +
  geom_line() +
  labs(title = "Length at Age for Bolbometopon muricatum",
       x = "Age (years)", y = "Length (mm)")

#Calculate age at sizes of 400, 500 and 600mm and baseline scenario
# Baseline scenario: A50 = 3, sel_delta = 5 (no size limit)
# Size limit scenarios: A50 based on size limit, sel_delta = 0.001 (knife-edge selectivity)
size_limit <- c(NA, 400, 500, 600)
sel_delta_vals <- c(0.0001, 0.0001, 0.0001, 0.0001) # Selectivity deltas for each size limit

A50vals <- vB_inverted(vbparams,size_limit)
A50vals[1] <- 3
slimdat <- data.frame(A50 = A50vals, size_limit = size_limit, sel_delta = sel_delta_vals)

#
# Plot selectivity curve
#

plot(seq(0, tmax, by = 0.1), logist(A50vals[1], sel_delta_vals[1], seq(0, tmax, by = 0.1)), type = "l")

# logist(A50vals[1], sel_delta_vals[1], seq(0, tmax, by = 1))

# Run sensitivity analysis for as50 (selectivity parameter) with varying sel_delta

# Create a function to run YPR analysis with both A50 and sel_delta parameters
run_ypr_scenario <- function(i) {
  ypr_sensitivity_analysis(H, age, vbparams, M, N0, WaA, sel_delta_vals[i], A50vals[i])
}

results_list <- purrr::map(1:length(A50vals), run_ypr_scenario)

#Calculate reference points 
ref_points <- map(results_list, calculate_reference_points) %>%
    bind_rows(.id = "scenario") %>%
    mutate(scenario_num = as.integer(scenario),
           A50 = A50vals[scenario_num],
           sel_delta = sel_delta_vals[scenario_num]) %>%
    select(-scenario) #remove temporary column

results <- bind_rows(results_list, .id = "scenario")
results <- results %>%
  mutate(scenario_num = as.integer(scenario),
         A50 = A50vals[scenario_num],
         sel_delta = sel_delta_vals[scenario_num]) %>%
  select(-scenario) #remove temporary column 

yield <- results

# Create scenario labels for plotting
yield <- yield %>%
  left_join(slimdat, by = c("A50", "sel_delta")) %>%
  mutate(scenario_label = case_when(
    is.na(size_limit)~ "Baseline (no size limit)",
    !is.na(size_limit) ~ paste0("Size limit: ", size_limit, "mm"),
    TRUE ~ "Other"
  ))

ref_points <- ref_points %>%
  left_join(slimdat, by = c("A50", "sel_delta")) %>%
  mutate(scenario_label = case_when(
    is.na(size_limit) ~ "Baseline (no size limit)",
    !is.na(size_limit) ~ paste0("Size limit: ", size_limit, "mm"),
    TRUE ~ "Other"
  ))

# Calculate reference points
print("Reference Points:")
print(ref_points)

 
# Plot yield curves using ggplot2
g1 <- ggplot(yield, aes(x = FF, y = Yield, color = scenario_label, group = scenario_label)) +
    geom_line(size = 1.2) +
    # geom_hline(yintercept = ref_points$Ymax, linetype = "dashed", color = "black") +
    # geom_vline(xintercept = ref_points$Fmax, linetype = "dashed", color = "black") +
    # geom_vline(xintercept = ref_points$F01, linetype = "dashed", color = "red") +
    labs(x = "Harvest Rate", y = "Yield", 
         color = "Scenario",
         title = "Yield per Recruit vs Harvest Rate") +
    theme_bw() + 
    theme(legend.position = "bottom")
g1


ggsave("Shared/Outputs/yield_per_recruit-validation.png", plot = g1, width = 10, height = 6)
# Create a summary table that includes the reference points for each scenario
summary_table <- ref_points %>%
    select(A50, Fmax, Ymax, F01, size_limit, scenario_label) %>%
    pivot_longer(cols = c(Fmax, Ymax, F01), names_to = "Reference Point", values_to = "Value") %>%
    mutate(`Reference Point` = factor(`Reference Point`, levels = c("Fmax", "Ymax", "F01"))) %>%
    select(scenario_label, size_limit, ref_point = `Reference Point`, A50, value = Value)

write.csv(summary_table, "Scripts/ypr-validation-case/ypr_reference_points.csv", row.names = FALSE)
