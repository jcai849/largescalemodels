\name{dlm}
\alias{dlm}
\title{
	Distributed Linear Model
}
\description{
	Folds an updating linear model over a distributed dataset
}
\usage{
dlm(formula, data, weights = NULL, sandwich = FALSE)
}
\arguments{
  \item{formula}{
	  A model formula
}
  \item{data}{
	  Reference to distributed dataframe
}
  \item{weights}{
	  A one-sided, single term formula specifying weights
}
  \item{sandwich}{
	  'TRUE' to compute the Huber/White sandwich covariance matrix
          (uses 'p^4' memory rather than 'p^2')
}
}
\value{
	Distributed object reference to the complete linear model
}
\author{
	Jason Cairns
}
