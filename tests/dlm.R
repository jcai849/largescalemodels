library(largescalemodelr)

source("taxi.R")
x <- dlm(tip_amount ~ trip_distance, taxicab)
x
