dlm <- function(formula, data, weights=NULL, sandwich=FALSE) {
	stopifnot(inherits(data, "DistributedObject"))
	stopifnot(length(as.list(data)) > 0L)
	init <- dbiglm(formula, as.list(data)[[1]], weights, sandwich)
	if (length(data) != 1L)
		largescaler::dreduce(f=biglm::update.biglm,
				     x=as.list(data)[[-1]],
				     init=init)
	else largescaler::DistributedObject(init)
}

dbiglm <- function(formula, data, weights=NULL, sandwich=FALSE) {
	sys.call <- curr_call_fun(-1)
	chunknet::do.ccall(list(largescalemodelr::biglm_fixed_call),
		           list(list(formula=benv(formula),
				   data=data,
				   weights=benv(weights),
				   sandwich=sandwich,
				   sys.call=benv(sys.call))),
			      target=list(data))
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
