source("write_load.R")

dbirthwt <- write_load(MASS::birthwt)
lbirthwt <- emerge(dbirthwt)
debug(dglm)
dbirthwtglm <- dglm(low ~ age + lwt + smoke, dbirthwt, fam=stats::binomial())
x
