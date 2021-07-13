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

y <- ddf$ArrDelay > 15
form <- y ~ DepDelay + DepTime + DayOfWeek

glmSetup <- function(form, y, X) {
	a <- ls()
	keep <- new.env(parent=baseenv())
	lapply(a, function(x) assign(x, get(x), keep))
	with(keep, {
		       fam	<- stats::binomial()
		       mm	<- stats::model.matrix(form, cbind(y, X))
		       beta	<- NULL
		       NOBS	<- NROW(y)
		       WEIGHTS	<- rep.int(1, NROW(y))
		       OFFSET	<- rep.int(0, NROW(y))
		       mustart	<- (WEIGHTS * y + 0.5)/(WEIGHTS + 1)
		       eta	<- fam$linkfun(mustart)
		       mu	<- fam$linkinv(eta)
		       mu.eta.val<- fam$mu.eta(eta)
		       z	<- (eta - OFFSET) + (y - mu) / mu.eta.val
		       w	<- sqrt((WEIGHTS * mu.eta.val^2) / fam$variance(mu))
	  })
	keep
}

init <- do.dcall(envBase(glmSetup), list(I(form), y, ddf))

#cat("\npreview of kept variables:\n")
#ls.str(emerge(chunkRef(init)[[3]]))

epsilon <- 1e-08
maxit <- 8

dev <- sum(do.dcall(envBase(function(keep) with(keep, fam$dev.resids(y, mu, WEIGHTS))),
		list(init)),
	   na.rm = TRUE)
#for (iter in 1L:maxit) {
XtX <- do.dcall(envBase(function(keep) with(keep, crossprod(mm[,,drop=FALSE] * w))),
		list(init))

final(1)
