library(largescalemodels)

test_data <- largescalemodels:::getAb()
dA <- test_data[[1]]
db <- test_data[[2]]
dpielasso <- dlasso(dA, db, tolerance=1, rho=3, lambda=3)
print("Distributed LASSO Coefficients:")
print(dpielasso)
Sys.sleep(3)
q("no")
