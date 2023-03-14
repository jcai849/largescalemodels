S <- function(kappa) function(alpha) pmax(alpha-kappa, 0) - pmax(-alpha-kappa, 0)
p_norm <- function(p) function(x) sum(abs(x)^p)^(1/p)
l1_norm <- p_norm(1)
euclid_norm <- l2_norm <- p_norm(2)
argmin <- function(init, f) optim(init, f)$par

d.x_update <- d(function(x_prev, A, b, u_prev, rho, z_prev)
                  argmin(x_prev,
                           function(x_prev) (1/2)*l2_norm(A %*% x_prev - b)^2 +
                                            (rho/2)*l2_norm(x_prev - z_prev + u_prev)^2))
d.z_update <- d(function(u_prev, x_curr, z_curr) u_prev + x_curr - z_curr)

dlasso <- function(A, b, tolerance=1, rho=3, lambda=rho) {
    n_chunks <- length(A)
    S_z <- S(lambda/(rho*n_chunks))

    z_prev <- x_prev <- u_prev <- rep(Inf, ncol(A))
    z_curr <- rep(1, ncol(A))
    i <- 0
    while (l1_norm(z_curr - z_prev) > tolerance) {
        cat("Iteration: ", i <- i+1, '\n')
        x_prev <- x_curr; z_prev <- z_curr; u_prev <- u_curr

        x_curr <- d.x_update(x_prev, A, b, u_prev, rho, z_prev)
        z_curr <- S_z(rowMeans(emerge(x_curr)) + rowMeans(emerge(u_curr)))
        u_curr <- d.z_update(u_prev, x_curr, z_curr)
    }
    z_curr
}