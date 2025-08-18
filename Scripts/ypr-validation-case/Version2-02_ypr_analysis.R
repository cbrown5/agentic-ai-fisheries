# Yield per recruit analysis for Bolbometopon muricatum
# Script 2: YPR calculations and reference point estimation

# Load required packages and previous script
source("scripts/01_ypr_parameters_functions.R")

# =============================================================================
# YPR CALCULATION FUNCTION
# =============================================================================

# Calculate yield per recruit for a given fishing mortality and selectivity parameters
calculate_ypr <- function(F_target, A50_value, delta_value = delta, 
                         ages = 0:max_age, M_value = M, 
                         initial_N = initial_recruitment) {
  
  # Initialize population vector
  N_at_age <- numeric(length(ages))
  N_at_age[1] <- initial_N  # Initial recruitment
  
  # Calculate selectivity at age
  sel_at_age <- selectivity(ages, A50_value, delta_value)
  
  # Calculate fishing mortality at age
  F_at_age <- F_target * sel_at_age
  
  # Calculate total mortality at age
  Z_at_age <- M_value + F_at_age
  
  # Population dynamics: calculate numbers at age
  for (i in 2:length(ages)) {
    N_at_age[i] <- N_at_age[i-1] * exp(-Z_at_age[i-1])
  }
  
  # Calculate catch at age using Baranov equation
  catch_at_age <- numeric(length(ages))
  for (i in 1:length(ages)) {
    if (Z_at_age[i] > 0) {
      catch_at_age[i] <- (F_at_age[i] / Z_at_age[i]) * N_at_age[i] * (1 - exp(-Z_at_age[i]))
    } else {
      catch_at_age[i] <- 0
    }
  }
  
  # Get weight at age
  weight_at_age <- life_history$weight_kg[ages + 1]  # +1 because life_history starts at age 0
  
  # Calculate yield (weight of catch)
  yield_at_age <- catch_at_age * weight_at_age
  total_yield <- sum(yield_at_age, na.rm = TRUE)
  
  return(list(
    F_target = F_target,
    total_yield = total_yield,
    N_at_age = N_at_age,
    catch_at_age = catch_at_age,
    yield_at_age = yield_at_age,
    F_at_age = F_at_age,
    sel_at_age = sel_at_age
  ))
}

# =============================================================================
# YPR CURVE CALCULATION
# =============================================================================

# Calculate YPR curve for a scenario
calculate_ypr_curve <- function(A50_value, F_range = seq(0, 1.5, by = 0.01)) {
  
  # Calculate YPR for each F value
  ypr_results <- map_dfr(F_range, ~ {
    result <- calculate_ypr(.x, A50_value)
    tibble(
      F = result$F_target,
      yield = result$total_yield
    )
  })
  
  return(ypr_results)
}

# =============================================================================
# REFERENCE POINT CALCULATION
# =============================================================================

# Calculate reference points from YPR curve
calculate_reference_points <- function(ypr_curve) {
  
  # Find Fmax and Ymax
  max_idx <- which.max(ypr_curve$yield)
  Fmax <- ypr_curve$F[max_idx]
  Ymax <- ypr_curve$yield[max_idx]
  
  # Calculate F01 (F where slope = 10% of slope at origin)
  # First, calculate slope at origin (using first few points)
  origin_points <- ypr_curve[1:5, ]
  slope_at_origin <- lm(yield ~ F, data = origin_points)$coefficients[2]
  target_slope <- 0.1 * slope_at_origin
  
  # Calculate slopes between consecutive points
  ypr_curve$slope <- c(NA, diff(ypr_curve$yield) / diff(ypr_curve$F))
  
  # Find F01 (first F where slope drops to 10% of origin slope)
  F01_idx <- which(ypr_curve$slope <= target_slope & !is.na(ypr_curve$slope))[1]
  F01 <- ifelse(is.na(F01_idx), NA, ypr_curve$F[F01_idx])
  
  return(list(
    Fmax = Fmax,
    Ymax = Ymax,
    F01 = F01,
    slope_at_origin = slope_at_origin,
    target_slope = target_slope
  ))
}

# =============================================================================
# ANALYZE ALL SCENARIOS
# =============================================================================

cat("Calculating YPR curves for all scenarios...\n")

# Define F range for analysis
F_range <- seq(0, 1.5, by = 0.01)

# Calculate YPR curves for each scenario
all_ypr_results <- list()
all_reference_points <- list()

for (i in 1:nrow(scenarios)) {
  scenario_name <- scenarios$scenario_label[i]
  A50_val <- scenarios$A50[i]
  
  cat(paste("Processing:", scenario_name, "\n"))
  
  # Calculate YPR curve
  ypr_curve <- calculate_ypr_curve(A50_val, F_range)
  ypr_curve$scenario <- scenario_name
  ypr_curve$A50 <- A50_val
  
  # Calculate reference points
  ref_points <- calculate_reference_points(ypr_curve)
  ref_points$scenario <- scenario_name
  ref_points$A50 <- A50_val
  
  # Store results
  all_ypr_results[[i]] <- ypr_curve
  all_reference_points[[i]] <- ref_points
  
  cat(paste("  Fmax:", round(ref_points$Fmax, 3), "\n"))
  cat(paste("  Ymax:", round(ref_points$Ymax, 3), "\n"))
  cat(paste("  F01:", round(ref_points$F01, 3), "\n\n"))
}

# Combine all results
ypr_all_scenarios <- bind_rows(all_ypr_results)
reference_points_all <- bind_rows(all_reference_points)

# =============================================================================
# SAVE RESULTS
# =============================================================================

# Save YPR curves
write_csv(ypr_all_scenarios, "data/ypr_curves_all_scenarios.csv")

# Save reference points
write_csv(reference_points_all, "data/reference_points_calculated.csv")

# Display summary
cat("YPR Analysis Complete!\n")
cat("======================\n")
print(reference_points_all %>% 
  select(scenario, A50, Fmax, Ymax, F01))

cat("\nResults saved to:\n")
cat("- data/ypr_curves_all_scenarios.csv\n")
cat("- data/reference_points_calculated.csv\n")