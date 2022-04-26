dglm <- function(formula, data, fam=stats::binomial(), verbose=FALSE) {
	stopifnot(inherits(data, "DistributedObject"))
	formula <- benv(formula)

	epsilon	<- 1e-08
	maxit	<- 30

	beta_hat	<- NULL
	mm		<- do.dcall(stats::model.matrix, list(formula, data))
	y 		<- do.dcall(function(data, mm, formula) matrix(data[rownames(mm),all.vars(form)[1]],ncol=1),
				    list(data=data, mm=mm, formula=formula))
	NOBS 		<- NROW(y)
	WEIGHTS		<- rep.int(1,NROW(y))
	OFFSET		<- rep.int(0,NROW(y))
	mustart		<- (WEIGHTS*y+0.5)/(WEIGHTS+1)
	eta		<- do.dcall(fam$linkfun, list(mustart))
	mu		<- do.dcall(fam$linkinv, list(eta))
	mu.eta.val	<- do.dcall(fam$mu.eta, list(eta))
	z		<-(eta-OFFSET)+(y-mu)/mu.eta.val
	w		<-sqrt((WEIGHTS*mu.eta.val^2)/fam$variance(mu))
	
	dev <- sum(do.dcall(fam$dev.resids, list(y, mu, WEIGHTS)))

	for (iter in 1L:maxit) { # reweighting:
		XtX <- emerge(do.dcall(function(mm, w) crossprod(mm[,,drop=FALSE] * as.numeric(w)), list(mm, w)))
		Xty <- emerge(do.dcall(function(mm, w, z) t(mm[,,drop=FALSE] * as.numeric(w)) %*% (z * as.numeric(w)), list(mm, w, z)))
		beta_hat <- solve(XtX, Xty)
			eta	<- do.dcall(function(mm, beta_hat, OFFSET) drop(mm %*% beta_hat) + OFFSET, list(mm, beta_hat, OFFSET))
			mu		<- do.dcall(fam$linkinv, list(eta))
			mu.eta.val	<- do.dcall(fam$mu.eta, list(eta))
			z		<-(eta-OFFSET)+(y-mu)/mu.eta.val
			w		<-sqrt((WEIGHTS*mu.eta.val^2)/fam$variance(mu))
		devold <- dev
		dev <- sum(do.dcall(fam$dev.resids, list(y, mu, WEIGHTS)))
		if (verbose) cat("Deviance = ", dev, " Iterations - ", iter, "\n", sep = "")
		if (abs(dev - devold)/(0.1 + abs(dev)) < epsilon) break
		gc()
	}
	emerge(beta_hat)
}
