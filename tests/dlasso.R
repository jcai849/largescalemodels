source("write_load.R")


m <- 20
n <- 50000
N <- 5
A <- matrix(runif(m*n), n, m)
A[,1] <- 1
x_actual <- matrix(0, m)
x_actual[c(1, 3, 14, 15, 9),] <- c(27, 1, 8, 2, 82)
b <- A %*% x_actual

write_load_matrix(A)
write_load_matrix(b)
dtime <- system.time(dpielasso <- dlasso(A, b, tolerance=1, rho=3, lambda=rho))