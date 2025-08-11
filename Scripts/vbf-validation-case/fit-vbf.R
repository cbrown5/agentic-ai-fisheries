 #vB growth curve fit to Pitcher and Macdonald derived seasonal data  

library(FSA)
library(car)

( vb <- makeGrowthFun(type = "von Bertalanffy") )

#
# Set parameters 
#

pars_true <- c(100, 0.2, -0.2)
label <- c("Linf","K","t0")  \
sigma_growth <- 5
tmax <- 20

#
# Simulate age at length data, with errors 
#

set.seed(123)
n <- 100
times <- seq(0, 20, by = 1)
n_per_time <- 100  # number of samples at each time point
times_rep <- rep(times, each = n_per_time)
length <- vb(times_rep, pars_true[1], pars_true[2], pars_true[3]) + rnorm(length(times_rep), sd = sigma_growth)

dat <- data.frame(age = times_rep, length = length)

plot(times_rep, length)
#add curve
lines(times, vB(pars_true, times), col = "red", lwd = 2)

write.csv(dat, file = "Scripts/vbf-validation-case/example_vb_data.csv", row.names = FALSE)

#
# Fit the model 
#

( f.starts <- findGrowthStarts(length~age,data=dat) )

f.fit <- nls(length~vb(age,Linf,K,t0),data=dat,start=f.starts)
f.fit
summary(f.fit)

vb <- makeGrowthFun(type = "von Bertalanffy")
param_start <- findGrowthStarts(length~age,data=dat)
f.fit <- nls(length~vb(age,Linf,K,t0),data=dat,param_start)
f.fit

f.boot1 <- Boot(f.fit)  # Be patient! Be aware of some non-convergence
confint(f.boot1, type = "perc")

