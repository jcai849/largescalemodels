dlm <-
function(formula, data, weights=NULL, sandwich=FALSE) {
        stopifnot(largeScaleR::is.distObjRef(data))
        chunks <- largeScaleR::chunkRef(data)
        stopifnot(length(chunks) > 0L)
        currcall <- sys.call()
        scform <- c(alist(...=), call("quote", currcall))
        init <- largeScaleR::do.ccall("biglm::biglm",
                         list(formula=largeScaleR::stripEnv(formula),
                              data=chunks[[1]],
                              weights=largeScaleR::stripEnv(weights),
                              sandwich=sandwich),
                         target=chunks[[1]],
                         mask=list(sys.call=scform))
        if (length(chunks) != 1L)
		largeScaleR::dreduce("biglm::update.biglm",
				     largeScaleR::distObjRef(chunks[-1]), init)
        else init
}
