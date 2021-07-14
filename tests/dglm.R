library(largeScaleR)
start(3)
cols <- c("Year"="integer","Month"="integer","DayofMonth"="integer",
          "DayOfWeek"="integer","DepTime"="integer","CRSDepTime"="integer",
          "ArrTime"="integer","CRSArrTime"="integer",
          "UniqueCarrier"="character","FlightNum"="integer","TailNum"="character",
          "ActualElapsedTime"="integer","CRSElapsedTime"="integer",
          "AirTime"="integer","ArrDelay"="integer", "DepDelay"="integer",
          "Origin"="character","Dest"="character","Distance"="integer",
          "TaxiIn"="integer","TaxiOut"="integer", "Cancelled"="integer",
          "CancellationCode"="character","Diverted"="integer",
          "CarrierDelay"="integer","WeatherDelay"="integer","NASDelay"="integer",
          "SecurityDelay"="integer","LateAircraftDelay"="integer")

ddf <- read.lcsv("~/1987.csv", header=TRUE, colTypes=cols, max.size=42*1024^2)

#cat("preview of distributed data frame:\n")
#preview(ddf)

glmSetup <- function(form, ddf) {
	a <- ls()
	keep <- new.env(parent=baseenv())
	lapply(a, function(x) assign(x, get(x), keep))
	with(keep, {
		     ddf$DepDelay[is.na(ddf$DepDelay)] <- 0
		     ddf$Late	<- ddf$DepDelay > 15
		     fam	<- stats::binomial()
		     beta	<- NULL
		     mm		<- stats::model.matrix(form, ddf)
		     y		<- matrix(ddf[rownames(mm), all.vars(form)[1]], ncol=1)
		     NOBS	<- NROW(y)
		     WEIGHTS	<- rep.int(1, NROW(y))
		     OFFSET	<- rep.int(0, NROW(y))
		     mustart	<- (WEIGHTS * y + 0.5)/(WEIGHTS + 1)
		     eta	<- fam$linkfun(mustart)
		     mu		<- fam$linkinv(eta)
		     mu.eta.val	<- fam$mu.eta(eta)
		     z		<- (eta - OFFSET) + (y - mu) / mu.eta.val
		     w		<- sqrt((WEIGHTS * mu.eta.val^2) / fam$variance(mu))
	  })
	keep
}

form <- Late ~ DepDelay + DepTime + DayOfWeek

init <- do.dcall(envBase(glmSetup), list(I(form), ddf))

#cat("\npreview of kept variables:\n")
#ls.str(emerge(chunkRef(init)[[3]]))

epsilon <- 1e-08
maxit <- 30

dev <- sum(do.dcall(envBase(function(keep) with(keep,
						fam$dev.resids(y, mu, WEIGHTS))),
		list(init)),
	   na.rm = TRUE)

for (iter in 1L:maxit) {
	XtX <- Reduce('+', lapply(chunkRef(do.dcall(envBase(function(keep) with(keep,
										crossprod(mm[,,drop=FALSE] * as.numeric(w)))),
						  list(init))),
				emerge))

	Xty <- Reduce('+', lapply(chunkRef(do.dcall(envBase(function(keep) with(keep,
										t(mm[,,drop=FALSE] * as.numeric(w)) %*% (z * as.numeric(w)))),
						  list(init))),
				emerge))
	beta <- solve(XtX, Xty)

	invisible(do.dcall(envBase(function(keep, beta_hat) {
					   assign("beta_hat", beta_hat, keep)
					   with(keep, {
							eta <- drop(mm %*% beta_hat) + OFFSET
							mu <- fam$linkinv(eta)
							mu.eta.val <- fam$mu.eta(eta)
							z <- (eta - OFFSET) + (y - mu) / mu.eta.val
							w <- sqrt((WEIGHTS * mu.eta.val^2) / fam$variance(mu))
							return(0L)
						  })
				}),
			   list(init, I(beta))))

	devold <- dev
	dev <- sum(do.dcall(envBase(function(keep) with(keep,
							fam$dev.resids(y, mu, WEIGHTS))),
			    list(init)),
		   na.rm = TRUE)

	cat("Deviance = ", dev, " Iterations - ", iter, "\n", sep = "")
	if (abs(dev - devold)/(0.1 + abs(dev)) < epsilon) break
}

final(1)
