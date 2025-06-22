\name{dlasso}
\alias{dlasso}
\title{dlasso}
\description{dlasso}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or standard data sets, see data().

## The function is currently defined as
function (A, b, tolerance = 1, rho = 3, lambda = rho) 
{
    M_N <- rev(dim(materialise(A)))
    m <- ncol(A)
    S_z <- S(lambda/(rho * M_N[2]))
    z_prev <- x_prev <- u_prev <- rep(Inf, m)
    z_curr <- rep(1, m)
    x_curr <- distribute(z_curr, where = A)
    u_curr <- distribute(z_curr, where = A)
    i <- 0
    while (l1_norm(z_curr - z_prev) > tolerance) {
        cat("Iteration: ", i <- i + 1, "\n")
        x_prev <- x_curr
        z_prev <- z_curr
        u_prev <- u_curr
        x_curr <- d.x_update(x_prev, A, b, u_prev, rho, z_prev)
        u_curr <- materialise(u_curr)
        x_curr <- materialise(x_curr)
        dim(x_curr) <- dim(u_curr) <- M_N
        u_curr <- dematerialise(u_curr)
        x_curr <- dematerialise(x_curr)
        z_curr <- S_z(rowMeans(emerge(x_curr)) + rowMeans(emerge(u_curr)))
        u_curr <- u_prev + x_curr - z_curr
    }
    z_curr
  }
}
