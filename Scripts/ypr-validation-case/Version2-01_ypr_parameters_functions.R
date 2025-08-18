# Yield per recruit analysis for Bolbometopon muricatum
# Script 1: Biological parameters and key functions

# Load required packages
library(tidyverse)
library(ggplot2)
library(purrr)

# Set plot theme
theme_set(theme_bw())

# =============================================================================
# BIOLOGICAL PARAMETERS
# =============================================================================

# Growth parameters (von Bertalanffy)
Linf <- 1070  # asymptotic length (mm)
K <- 0.15     # growth coefficient (per year)
t0 <- -0.074  # theoretical age at length zero (years)

# Mortality and recruitment parameters
M <- 0.169            # instantaneous natural mortality rate (per year)
max_age <- 29         # maximum age (years)
initial_recruitment <- 1000  # initial number of recruits

# Length-weight relationship parameters
a <- 1.168e-6  # length-weight coefficient
b <- 3.409     # length-weight exponent
# Note: Length in mm, weight in grams

# Selectivity parameters
delta <- 0.001  # selectivity slope parameter
A50_baseline <- 3  # age at 50% selectivity for baseline scenario (years)

# Size limits for scenarios (mm)
size_limits <- c(400, 500, 600)

# =============================================================================
# KEY FUNCTIONS
# =============================================================================

# Von Bertalanffy growth equation
# Returns length at age (mm)
von_bertalanffy <- function(age, Linf, K, t0) {
  Linf * (1 - exp(-K * (age - t0)))
}

# Inverse von Bertalanffy equation (age at length)
# Returns age at specified length (years)
inverse_von_bertalanffy <- function(length, Linf, K, t0) {
  (log(1 - length / Linf) / -K) + t0
}

# Length to weight conversion
# Length in mm, returns weight in grams
length_to_weight <- function(length, a, b) {
  a * length^b
}

# Weight conversion from grams to kg
grams_to_kg <- function(weight_g) {
  weight_g / 1000
}

# Logistic selectivity function
# Returns selectivity (0-1) at age
selectivity <- function(age, A50, delta) {
  1 / (1 + exp(-log(19) * (age - A50) / delta))
}

# Baranov catch equation
# Returns catch at age
baranov_catch <- function(F_at_age, N_at_age, M) {
  Z_at_age <- M + F_at_age
  (F_at_age / (M + F_at_age)) * N_at_age * (1 - exp(-Z_at_age))
}

# =============================================================================
# SCENARIO SETUP
# =============================================================================

# Create age vector
ages <- 0:max_age

# Calculate A50 values for each size limit scenario
calculate_A50_for_size_limit <- function(size_limit_mm) {
  inverse_von_bertalanffy(size_limit_mm, Linf, K, t0)
}

# Calculate A50 for each scenario
A50_400mm <- calculate_A50_for_size_limit(400)
A50_500mm <- calculate_A50_for_size_limit(500)
A50_600mm <- calculate_A50_for_size_limit(600)

# Create scenario data frame
scenarios <- tibble(
  scenario_label = c("Baseline (no size limit)", 
                     "Size limit: 400mm", 
                     "Size limit: 500mm", 
                     "Size limit: 600mm"),
  size_limit = c(NA, 400, 500, 600),
  A50 = c(A50_baseline, A50_400mm, A50_500mm, A50_600mm)
)

# Print A50 values
cat("Age at 50% selectivity (A50) for each scenario:\n")
print(scenarios)

# =============================================================================
# BASIC LIFE HISTORY CALCULATIONS
# =============================================================================

# Calculate length and weight at age for all ages
life_history <- tibble(
  age = ages,
  length_mm = von_bertalanffy(age, Linf, K, t0),
  weight_g = length_to_weight(length_mm, a, b),
  weight_kg = grams_to_kg(weight_g)
)

# Display basic life history
cat("\nLife history parameters (first 10 ages):\n")
print(head(life_history, 10))

# Save intermediate results
if (!dir.exists("data")) dir.create("data")
write_csv(scenarios, "data/scenarios.csv")
write_csv(life_history, "data/life_history.csv")

cat("\nScript 1 completed successfully!\n")
cat("A50 values calculated and saved.\n")
cat("Life history data saved to data/life_history.csv\n")
cat("Scenario data saved to data/scenarios.csv\n")