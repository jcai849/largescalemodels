source("write_load.R")

dbirthwt <- write_load(MASS::birthwt)
lbirthwt <- largescaleobjects::emerge(dbirthwt)
dtime <- system.time(dbirthwtglm <- dglm(low ~ age + lwt + smoke, dbirthwt, fam=stats::binomial()))
ltime <- system.time(lbirthwtglm <- glm(low ~ age + lwt + smoke, MASS::birthwt, fam=stats::binomial()))