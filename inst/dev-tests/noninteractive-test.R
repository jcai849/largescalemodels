#!/usr/bin/env Rscript

source("write_load.R")

largescaleobjects::init_locator(LOC_HOST, LOC_PORT)
mapply(largescaleobjects::init_worker, "localhost", 9001L:9003L)

Sys.sleep(2)

dbirthwt <- write_load(MASS::birthwt)
lbirthwt <- largescaleobjects::emerge(dbirthwt)
dtime <- system.time(dbirthwtglm <- dglm(low ~ age + lwt + smoke, dbirthwt, fam=stats::binomial()))
ltime <- system.time(lbirthwtglm <- glm(low ~ age + lwt + smoke, MASS::birthwt, fam=stats::binomial()))
