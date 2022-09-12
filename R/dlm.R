dlm <- function(formula, data, weights=NULL, sandwich=FALSE) {
	if (!isNamespaceLoaded("biglm")) {
		loadNamespace("biglm")
		on.exit(unloadNamespace("biglm"))
	}
	stopifnot(inherits(data, "DistributedObject"))
	stopifnot(length(as.list(data)) > 0L)
	init <- dbiglm(formula, as.list(data)[[1]], weights, sandwich)
	if (length(as.list(data)) != 1L)
		largescaler::dReduce(f=update_dlm,
				     x=as.list(data)[-1],
				     init=init)
	else largescaler::DistributedObject(init)
}

update_dlm <- function(x, y) {
	loadNamespace("biglm")
	on.exit(unloadNamespace("biglm"))
	update(x, y)
}

dbiglm <- function(formula, data, weights=NULL, sandwich=FALSE) {
	sys.call <- curr_call_fun(-1)
	chunknet::do.ccall(list(biglm_fixed_call),
		           list(list(formula=benv(formula),
				     data=data,
				     weights=benv(weights),
				     sandwich=sandwich,
				     sys.call=benv(sys.call))),
			    target=data)
}

biglm_fixed_call <- function(formula, data, weights, sandwich, sys.call) {
	rval <- biglm::biglm(formula, data, weights, sandwich)
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
