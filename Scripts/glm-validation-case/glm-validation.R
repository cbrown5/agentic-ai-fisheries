library(tidyverse)
library(visreg)
library(MASS)

# =============================================================================
# DATA WRANGLING
# =============================================================================

dat <- readr::read_csv("Scripts/glm-test-case/data/fish-coral.csv")

# Calculate percent cover
dat <- dat %>%
  mutate(
    CB_cover_pct = CB_cover / n_pts * 100,
    soft_cover_pct = soft_cover / n_pts * 100
  )

# =============================================================================
# MODEL FITTING AND SELECTION
# =============================================================================

# Fit negative binomial GLM with interaction
model_full <- MASS::glm.nb(pres.topa ~ soft_cover_pct * CB_cover_pct, data = dat)

# Fit reduced models for comparison
model_additive <- MASS::glm.nb(pres.topa ~ soft_cover_pct + CB_cover_pct, data = dat)

lr_interaction <- anova(model_additive, model_full, test = "Chisq")
lr_interaction

best_model <- model_full

# =============================================================================
# MODEL VERIFICATION
# =============================================================================

# Create verification plots directory
dir.create("Scripts/glm-validation-case/verification_plots", showWarnings = FALSE)

# Diagnostic plots
png("Scripts/glm-validation-case/verification_plots/residuals_vs_fitted.png", 
    width = 800, height = 600)
plot(fitted(best_model), residuals(best_model, type = "pearson"),
     xlab = "Fitted values", ylab = "Pearson residuals",
     main = "Residuals vs Fitted")
abline(h = 0, col = "red", lty = 2)
dev.off()

# Q-Q plot
png("Scripts/glm-validation-case/verification_plots/qq_plot.png", 
    width = 800, height = 600)
qqnorm(residuals(best_model, type = "pearson"))
qqline(residuals(best_model, type = "pearson"), col = "red")
dev.off()

# Predicted vs observed
png("Scripts/glm-validation-case/verification_plots/predicted_vs_observed.png", 
    width = 800, height = 600)
plot(dat$pres.topa, fitted(best_model),
     xlab = "Observed count", ylab = "Predicted count",
     main = "Predicted vs Observed")
abline(0, 1, col = "red", lty = 2)
dev.off()

# Predicted versus observed distribution of counts

ggplot(dat, aes(x = pres.topa)) +
  geom_histogram(aes(y = ..density..), bins = 30, fill = "lightblue", color = "black") +
  geom_histogram(aes(y = ..density.., x = fitted(best_model)), 
               color = "red", size = 0.5, alpha = 0.5) +
  labs(x = "Observed count", y = "Density",
       title = "Predicted vs Observed Distribution of Counts") +
  theme_minimal()
ggsave("Scripts/glm-validation-case/verification_plots/predicted_vs_observed_distribution.png", 
       width = 8, height = 6)

# Cook's distance
png("Scripts/glm-validation-case/verification_plots/cooks_distance.png", 
    width = 800, height = 600)
plot(cooks.distance(best_model), type = "h",
     xlab = "Observation", ylab = "Cook's distance",
     main = "Cook's Distance")
abline(h = 4/nrow(dat), col = "red", lty = 2)
dev.off()

# =============================================================================
# SUMMARY FIGURES
# =============================================================================

# Create summary plots directory
dir.create("Scripts/glm-validation-case/summary_plots", showWarnings = FALSE)
# Visreg plots with 95% CI using gg = TRUE

    # Soft coral cover effect
    p_soft <- visreg(best_model, "soft_cover_pct", scale = "linear", gg = TRUE) +
        labs(x = "Soft coral cover (%)", y = "Predicted count")
    ggsave("Scripts/glm-validation-case/summary_plots/soft_cover_effect.png", 
           plot = p_soft, width = 8, height = 6)

    # CB cover effect
    p_cb <- visreg(best_model, "CB_cover_pct", scale = "linear", gg = TRUE) +
        labs(x = "CB cover (%)", y = "Predicted count")
    ggsave("Scripts/glm-validation-case/summary_plots/cb_cover_effect.png", 
           plot = p_cb, width = 8, height = 6)

    # Interaction effect
    p_interaction <- visreg(best_model, "CB_cover_pct", by = "soft_cover_pct", scale = "linear", gg = TRUE) +
        labs(x = "CB cover (%)", y = "Predicted count", color = "Soft coral cover (%)")
    ggsave("Scripts/glm-validation-case/summary_plots/interaction_effect.png", 
           plot = p_interaction, width = 8, height = 6)

        # Scatter plot of CB cover vs soft coral cover
        p_cb_vs_soft <- ggplot(dat, aes(x = CB_cover_pct, y = soft_cover_pct)) +
            geom_point(alpha = 0.7) +
            labs(x = "CB cover (%)", y = "Soft coral cover (%)",
                     title = "CB Cover vs Soft Coral Cover") +
            theme_minimal()

# =============================================================================
# SUMMARY STATISTICS
# =============================================================================

cat("=============================================================================\n")
cat("GLM VALIDATION RESULTS\n")
cat("=============================================================================\n\n")

cat("BEST MODEL SUMMARY:\n")
cat("-------------------\n")
print(summary(best_model))

cat("\n\nMODEL SELECTION RESULTS:\n")
cat("------------------------\n")
print(aic_comparison)

cat("\n\nLIKELIHOOD RATIO TEST RESULTS:\n")
cat("------------------------------\n")

cat("\nInteraction effect test:\n")
print(lr_interaction)

cat("\nSoft cover effect test:\n")
print(lr_soft)

cat("\nCB cover effect test:\n")
print(lr_cb)

cat("\nOverall model test:\n")
print(lr_overall)

cat("\n\nMODEL DIAGNOSTICS:\n")
cat("------------------\n")
cat("Deviance:", deviance(best_model), "\n")
cat("Degrees of freedom:", df.residual(best_model), "\n")
cat("Dispersion parameter:", best_model$theta, "\n")
cat("Log-likelihood:", logLik(best_model), "\n")

cat("\n\nPLOTS SAVED TO:\n")
cat("---------------\n")
cat("Verification plots: Scripts/glm-validation-case/verification_plots/\n")
cat("Summary plots: Scripts/glm-validation-case/summary_plots/\n")

