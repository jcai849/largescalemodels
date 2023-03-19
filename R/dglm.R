dglm <- function(formula, data, fam=stats::binomial(), verbose=FALSE) {
	stopifnot(inherits(data, "DistributedObject"))
	environment(formula) <- baseenv()

	d.XtX		<- d(function(mm, w) as.ColSplit(crossprod(mm[,,drop=FALSE] * as.numeric(w))))
	d.Xty		<- d(function(mm, w, z) as.ColSplit(t(mm[,,drop=FALSE] * as.numeric(w)) %*% (z * as.numeric(w))))
	d.dev.resids	<- d(fam$dev.resids)
	d.eta		<- d(function(mm, beta_hat, OFFSET) drop(mm %*% beta_hat) + OFFSET)
	d.linkfun	<- d(fam$linkfun)
	d.linkinv	<- d(fam$linkinv)
	d.model.matrix	<- d(stats::model.matrix)
	d.mu.eta	<- d(fam$mu.eta)
	d.variance	<- d(fam$variance)
	d.y		<- d(function(data, mm, formula) matrix(data[rownames(mm), all.vars(formula)[1]], ncol=1))

	epsilon	<- 1e-08
	maxit	<- 30

	mm		<- d.model.matrix(formula, data)
	y 		<- d.y(data, mm, formula)
	WEIGHTS		<- 1
	OFFSET		<- 0
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

	beta_hat[]
}

combine.ColSplit <- function(x, ...) rowSums(simplify2array(x), dims=2)
as.ColSplit <- function(x) {
	class(x) <- unique.default(c("ColSplit", oldClass(x)))
	x
}
