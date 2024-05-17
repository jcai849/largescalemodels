library(largescalemodels)

print(dA)
print(db)
dpielasso <- dlasso(dA, db, tolerance=1, rho=3, lambda=3)
print("Distributed LASSO Coefficients:")
print(dpielasso)
Sys.sleep(3)
q("no")
