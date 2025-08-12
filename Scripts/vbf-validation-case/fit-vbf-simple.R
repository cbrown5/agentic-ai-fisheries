 #vB growth curve fit to Pitcher and Macdonald derived seasonal data  
# this version uses base R and boot

vb <- function(age, Linf, K, t0) {
  Linf * (1 - exp(-K * (age - t0)))
}

#
# Set parameters 
#

pars_true <- c(100, 0.2, -0.2)
label <- c("Linf","K","t0")  
sigma_growth <- 8
tmax <- 20

#
# Simulate age at length data, with errors 
#

set.seed(123)
times <- seq(0, 20, by = 1)
n_per_time <- 10  # number of samples at each time point
times_rep <- rep(times, each = n_per_time)
length <- vb(times_rep, pars_true[1], pars_true[2], pars_true[3]) + rnorm(length(times_rep), sd = sigma_growth)

dat <- data.frame(age = times_rep, length = length)

plot(times_rep, length)
#add curve
lines(times_rep, vb(times_rep,pars_true[1], pars_true[2], pars_true[3]), col = "red", lwd = 2)

write.csv(dat, file = "Scripts/vbf-validation-case/example_vb_data.csv", row.names = FALSE)

#
# Fit the model 
#
f.starts <- function(data) {
  start <- c(Linf = max(data$length), K = 0.1, t0 = 0)
  return(start)
}

f.fit <- nls(length~vb(age,Linf,K,t0),data=dat,start=f.starts)
f.fit
summary(f.fit)

f.boot1 <- boot::boot(data = dat, statistic = function(data, indices) {
  d <- data[indices, ]
  fit <- nls(length ~ vb(age, Linf, K, t0), data = d, start = f.starts(d))
  return(coef(fit))
}, R = 1000)

f.boot1
confint <- function(boot_obj, type = "perc") {
  if (type == "perc") {
    return(apply(boot_obj$t, 2, quantile, probs = c(0.025, 0.975)))
  } else {
    stop("Unsupported confidence interval type")
  }
}   

confint(f.boot1, type = "perc")

pred_age <- 5
pred_length <- predict(f.fit, newdata = data.frame(age = pred_age))
cat("Predicted length at age 5:", pred_length, "\n")    

#bootstrap length at age 5
boot_pred <- function(age, boot_obj) {
  pred <- sapply(1:nrow(boot_obj$t), function(i) {
    vb(age, boot_obj$t[i, 1], boot_obj$t[i, 2], boot_obj$t[i, 3])
  })
  return(pred)
}           

boot_length_at_age_5 <- boot_pred(pred_age, f.boot1)
cat("Bootstrap predicted lengths at age 5:", boot_length_at_age_5, "\n")
cat("Mean bootstrap predicted length at age 5:", mean(boot_length_at_age_5), "\n")
cat("95% CI for bootstrap predicted length at age 5:", quantile(boot_length_at_age_5, probs = c(0.025, 0.975)), "\n")

