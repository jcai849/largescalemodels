\name{dlm}
\alias{dlm}
\title{dlm}
\description{dlm}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or standard data sets, see data().

## The function is currently defined as
function (formula, data, weights = NULL, sandwich = FALSE) 
{
    stopifnot(inherits(data, "DistributedObject"))
    stopifnot(length(as.list(data)) > 0L)
    init <- dbiglm(formula, as.list(data)[[1]], weights, sandwich)
    if (length(as.list(data)) != 1L) 
        largescaleobjects::dReduce(f = update, x = as.list(data)[-1], 
            init = init)
    else largescaleobjects::DistributedObject(init)
  }
}
