source("write_load.R")

dbirthwt <- write_load(MASS::birthwt)
lbirthwt <- largescaler::emerge(dbirthwt)
dbirthwtglm <- dglm(low ~ age + lwt + smoke, dbirthwt, fam=stats::binomial())
lbirthwtglm <- glm(low ~ age + lwt + smoke, MASS::birthwt, fam=stats::binomial())
