library(largescaler)
library(largescalemodelr)

ADDRS <- paste0("fosstatsprd0", 2:4, ".its.auckland.ac.nz")
PATHS <- "/course/data/airline/sample"

init_locator(ADDRS[1], 9000L)
mapply(init_worker, rep(ADDRS, each=2), 9001L:9002L)

lairline <- read.csv(PATHS[1], nrows=20)
col.names <- colnames(lairline)
colClasses <- vapply(lairline, class, character(1), USE.NAMES=FALSE)
dairline <- read.dcsv(paste(ADDRS, PATHS, sep=':'), col.names=col.names, colClasses=colClasses)

dairlinelm <- dlm(ArrDelay ~ AirTime * Distance, data=dairline)
dairlineglm <- dglm(Cancelled ~ Year + SecurityDelay, data=dairline, fam=stats::binomial())
