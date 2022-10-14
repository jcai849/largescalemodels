library(largescaler)
library(largescalemodelr)

ADDRS <- paste0("fosstatsprd0", 2:4, ".its.auckland.ac.nz")
PATHS <- list.files("/course/data/airline/full", full.names=TRUE)

#init_locator(ADDRS[1], 9000L)
#mapply(init_worker, rep(ADDRS, each=2), 9001L:9002L)
orcv::start()
chunknet::LOCATOR("localhost", 9000L)

lairline <- read.csv(PATHS[length(PATHS)], nrows=1000)
col.names <- colnames(lairline)
colClasses <- vapply(lairline, class, character(1), USE.NAMES=FALSE)

dairline <- read.dcsv(PATHS, col.names=col.names, colClasses=colClasses, header=T)

#dairlinelm <- dlm(ArrDelay ~ DepDelay + Distance, data=dairline)
#dairlineglm <- dglm(Cancelled ~ Year + SecurityDelay, data=dairline, fam=stats::binomial())
