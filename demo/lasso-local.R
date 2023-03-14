#!/usr/bin/env Rscript

# Params
m <- 20
n <- 50000
N <- 5

lambda <- 3
rho <- 3
tolerance <- 1
kappa <- lambda/(rho*N)

# Functions
S <- function(alpha) pmax(alpha-kappa, 0) - pmax(-alpha-kappa, 0)
p_norm <- function(p) function(x) sum(abs(x)^p)^(1/p)
l1_norm <- p_norm(1)
euclid_norm <- l2_norm <- p_norm(2)
argmin <- function(init, f) optim(init, f)$par

# Data
A <- matrix(runif(m*n), n, m)
A[,1] <- 1
x_actual <- matrix(0, m)
x_actual[c(1, 3, 14, 15, 9),] <- c(27, 1, 8, 2, 82)
b <- A %*% x_actual

chunks_i <- tapply(seq(n), cut(seq(n), N), identity, simplify=F)
A <- lapply(chunks_i, function(i, x) x[i,], A)
b <- lapply(chunks_i, function(i, x) x[i], b)

# Initial vals

z_prev <- rep(Inf, m)
x_prev <- u_prev <- rep(list(z_prev), N)
z_curr <- rep(1, m)
x_curr <- u_curr <- rep(list(z_curr), N)
i <- 0

# ADMM Loop
while (l1_norm(z_curr - z_prev) > tolerance) {
    cat("Iteration: ", i <- i+1, '\n')
    x_prev <- x_curr; z_prev <- z_curr; u_prev <- u_curr

    x_curr <- mapply(function(x_prev, A, b, u_prev, rho, z_prev)
                            argmin(x_prev, function(x_prev) (1/2)*l2_norm(A %*% x_prev - b)^2 + (rho/2)*l2_norm(x_prev - z_prev + u_prev)^2),
                    x_prev, A, b, u_prev,
                    MoreArgs = list(rho, z_prev), SIMPLIFY = FALSE)
    z_curr <- S(rowMeans(array(unlist(x_curr), dim=list(m, N))) + rowMeans(array(unlist(u_curr), dim=list(m, N))))
    u_curr <- mapply(function(u_prev, x_curr, z_curr) u_prev + x_curr - z_curr,
                    u_prev, x_curr,
                    MoreArgs = list(z_curr), SIMPLIFY = FALSE)
}
cat("Iteration complete.\n\n")
cat("Estimated and actual x:\n")
for (i in seq(m))cat(format(cbind(z_curr, x_actual))[i,], '\n')