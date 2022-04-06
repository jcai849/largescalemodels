dlm <- function(formula, data, weights=NULL, sandwich=FALSE) {
	stopifnot(inherits(data, "DistributedObject"))
	stopifnot(length(unclass(data)) > 0L)
	init <- dbiglm(formula, data[[1]], weights, sandwich)
	if (length(data) != 1L)
		largescaler::dreduce(f=biglm::update.biglm,
				     x=largescaler::data[-1],
				     init=init)
	else init
}

dbiglm <- function(formula, data, weights=NULL, sandwich=FALSE) {
	stopifnot(inherits(data, "DistributedObject"))
	sys.call <- curr_call_fun(-1)
	largescaler::do.dcall(largescalemodelr::biglm_fixed_call,
			      list(formula=benv(formula),
				   data=data,
				   weights=benv(weights),
				   sandwich=sandwich,
				   sys.call=benv(sys.call)),
			      target=data)
}

biglm_fixed_call <- function(formula, data, weights, sandwich, sys.call) {
	rval <- biglm::biglm(formula, data, weights, sandwich)
	rval$call <- sys.call
	rval
}

curr_call_fun <- function(n=0) {
	cl <- sys.call(n-1)
	as.function(c(alist(...=), call("quote", cl)))
}

benv <- function(x) {
        if (missing(x)) return(baseenv())
        if (!is.null(x)) attr(x, ".Environment") <- baseenv()
        x
}
