library(largescalemodelr)

source("taxi.R")
x <- dglm(passenger_count ~ tip_amount, fam=stats::poisson(), taxicab)
x
