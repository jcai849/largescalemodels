dglm <- function(formula, data, fam=stats::binomial(), verbose=FALSE) {
	stopifnot(inherits(data, "DistributedObject"))
	formula <- benv(formula)

	d.model.matrix	<- d(stats::model.matrix)
	d.linkfun	<- d(fam$linkfun)
	d.linkinv	<- d(fam$linkinv)
	d.mu.eta	<- d(fam$mu.eta)
	d.dev.resids	<- d(fam$dev.resids)
	d.variance	<- d(fam$variance)
	d.y		<- d(function(data, mm, formula) matrix(data[rownames(mm), all.vars(formula)[1]], ncol=1))
	d.XtX		<- d(function(mm, w) crossprod(mm[,,drop=FALSE] * as.numeric(w)))
	d.Xty		<- d(function(mm, w, z) t(mm[,,drop=FALSE] * as.numeric(w)) %*% (z * as.numeric(w)))
	d.eta		<- d(function(mm, beta_hat, OFFSET) drop(mm %*% beta_hat) + OFFSET)

	epsilon	<- 1e-08
	maxit	<- 30

	beta_hat	<- NULL
	mm		<- d.model.matrix(formula, data)
	y 		<- d.y(data, mm, formula)
	NOBS 		<- NROW(y)
	WEIGHTS		<- rep.int(1, NROW(y))
	OFFSET		<- rep.int(0, NROW(y))
	mustart		<- (WEIGHTS * y + 0.5) / (WEIGHTS + 1)
	eta		<- d.linkfun(mustart)
	mu		<- d.linkinv(eta)
	mu.eta.val	<- d.mu.eta(eta)
	z		<- (eta - OFFSET) + (y - mu) / mu.eta.val
	w		<- sqrt((WEIGHTS * mu.eta.val^2) / d.variance(mu))
	
	dev <- sum(d.dev.resids(y, mu, WEIGHTS))

	for (iter in 1L:maxit) { # reweighting:
		XtX		<- d.XtX(mm, w)
		Xty		<- d.Xty(mm, w, z)
		beta_hat 	<- solve(XtX, Xty)
		eta		<- d.eta(mm, beta_hat, OFFSET)
		mu		<- d.linkinv(eta)
		mu.eta.val	<- d.mu.eta(eta)
		z		<- (eta - OFFSET) + (y - mu) / mu.eta.val
		w		<- sqrt((WEIGHTS * mu.eta.val^2) / d.variance(mu))
		devold <- dev
		dev <- sum(d.dev.resids(y, mu, WEIGHTS))
		if (verbose) cat("Deviance = ", dev, " Iterations - ", iter, "\n", sep = "")
		if (abs(dev - devold)/(0.1 + abs(dev)) < epsilon) break
		gc()
	}

	emerge(beta_hat)
}
