
## Function for von Bertalanffy growth equation
vB <- function(pars, age) {
   # pars: vector of parameters c(Linf, k, t0)
   Linf <- pars[1]
   k <- pars[2]
   t0 <- pars[3]
   Linf * (1 - exp(-k * (age - t0)))
}

vB_inverted <- function(pars, length) {
   # Inverse of the von Bertalanffy growth equation
   Linf <- pars[1]
   k <- pars[2]
   t0 <- pars[3]
   (log(1 - length / Linf) / -k) + t0
}

## Function for length to weight conversion
length_to_weight <- function(length, a = 0.015, b = 3.0) {
   # length in cm, returns weight in grams
   a * length^b
}

## Function for logistic selectivity
logist <- function(A50, delta, A) {
  1/(1 + exp(-log(19) * (A - A50)/(delta)))
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
    arrange(H) %>%
    summarise(
      Fmax = FF[which.max(Yield)],
      Ymax = max(Yield),
      # F0.1 approximation (fishing mortality at 10% of initial slope)
      initial_slope = (Yield[2] - Yield[1]) / (FF[2] - FF[1]),
      target_slope = 0.1 * initial_slope,
      .groups = "drop"
    )
  
    # Find F0.1
    datf01 <- yield_data %>%
        arrange(FF) %>%
        mutate(slope = c(NA, diff(Yield) / diff(FF)))
    idx <- which.min(abs(datf01$slope - ref_points$target_slope)) 
    ref_points$F01 <- datf01$FF[idx]

  return(ref_points)
}


## Function for YPR sensitivity analysis
ypr_sensitivity_analysis <- function(H, age, vbparams, M, N0, WaA,sel_delta, A50) {
  
  FF <- -log(1 - H)  # Fully selected fishing mortality
  nH <- length(H)
  nage <- length(age)
  sa <- logist(A50, sel_delta, age)  # Selectivity at age

  # Storage matrices
  numt <- matrix(0, nrow = nage, ncol = nH, dimnames = list(age, FF))
  catchN <- matrix(0, nrow = nage, ncol = nH, dimnames = list(age, FF))
  
    # Calculate yield for each harvest rate
    yield_temp <- rep(0, nH)
    
    for (harv in seq_along(H)) {
      Ft <- sa * FF[harv]  # Fishing mortality-at-age
      out <- bce(M, Ft, N0, age)
      numt[, harv] <- out[, "Nt"]
      catchN[, harv] <- out[, "Catch"]
      yield_temp[harv] <- sum(out[, "Catch"] * WaA, na.rm = TRUE)
    }
    
    # Store yield results
    yield_results <- data.frame(H = H,
                                   FF = FF,
                                   Yield = yield_temp)
  
    # Calculate reference points 

  return(yield_results)
}
