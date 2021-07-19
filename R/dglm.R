dglm <- function(formula, data, verbose=FALSE) {
	stopifnot(is.distObjRef(data))
	epsilon	<- 1e-08
	maxit	<- 30
	de	<- denvRef(data)
	with(de, { # initialise
		fam		<-stats::binomial()
		beta_hat	<-NULL
		mm		<-stats::model.matrix(form, data)
		y		<-matrix(data[rownames(mm),all.vars(form)[1]],ncol=1)
		NOBS		<-NROW(y)
		WEIGHTS		<-rep.int(1,NROW(y))
		OFFSET		<-rep.int(0,NROW(y))
		mustart		<-(WEIGHTS*y+0.5)/(WEIGHTS+1)
		eta		<-fam$linkfun(mustart)
		mu		<-fam$linkinv(eta)
		mu.eta.val	<-fam$mu.eta(eta)
		z		<-(eta-OFFSET)+(y-mu)/mu.eta.val
		w		<-sqrt((WEIGHTS*mu.eta.val^2)/fam$variance(mu))
	  },
	  list(formula=I(formula), data=data), result=FALSE)
	dev <- sum(with(de, fam$dev.resids(y, mu, WEIGHTS)))
	for (iter in 1L:maxit) { # reweightin:
		XtX <- emerge(with(de, crossprod(mm[,,drop=FALSE] * as.numeric(w))))
		Xty <- emerge(with(de, t(mm[,,drop=FALSE] * as.numeric(w)) %*% (z * as.numeric(w))))
		beta_hat <- solve(XtX, Xty)
		with(de, { # update beta hat
			     eta	<- drop(mm %*% beta_hat) + OFFSET
			     mu		<- fam$linkinv(eta)
			     mu.eta.val	<- fam$mu.eta(eta)
			     z		<- (eta - OFFSET) + (y - mu) / mu.eta.val
			     w		<- sqrt((WEIGHTS * mu.eta.val^2) / fam$variance(mu))
		  }, list(beta_hat=I(beta_hat)), result=FALSE)
		devold <- dev
		dev <- sum(with(de, fam$dev.resids(y, mu, WEIGHTS)))
		if (verbose) cat("Deviance = ", dev, " Iterations - ", iter, "\n", sep = "")
		if (abs(dev - devold)/(0.1 + abs(dev)) < epsilon) break
	}
	emerge(with(de, beta_hat))
}
