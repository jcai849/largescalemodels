dlm <- function(formula, data, weights=NULL, sandwich=FALSE) {
	stopifnot(inherits(data, "DistributedObject"))
	stopifnot(length(as.list(data)) > 0L)
	init <- dbiglm(formula, as.list(data)[[1]], weights, sandwich)
	if (length(as.list(data)) != 1L)
		largescaleobjects::dReduce(f=update,
				     x=as.list(data)[-1],
				     init=init)
	else largescaleobjects::DistributedObject(init)
}

dbiglm <- function(formula, data, weights=NULL, sandwich=FALSE) {
	sys.call <- curr_call_fun(-1)
	largescalechunks::do.ccall(list(biglm_fixed_call),
		           list(list(formula=benv(formula),
				     data=data,
				     weights=benv(weights),
				     sandwich=sandwich,
				     sys.call=benv(sys.call))),
			    target=data)[[1]]
}

biglm_fixed_call <- function(formula, data, weights, sandwich, sys.call) {
	library(biglm)
	rval <- biglm(formula, data, weights, sandwich)
	rval$call <- substitute(sys.call)
	rval
}

curr_call_fun <- function(n=0) {
	cl <- sys.call(n-1)
	attr(cl, "srcref") <- NULL
	cl
}

benv <- function(x) {
        if (missing(x)) return(baseenv())
        if (!is.null(attr(x, ".Environment"))) attr(x, ".Environment") <- baseenv()
        x
}
