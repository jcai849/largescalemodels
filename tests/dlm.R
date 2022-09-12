library(largescalemodelr)
library(largescaler)

LOC_HOST <- "localhost"
LOC_PORT <- 9000L

orcv::start()
chunknet::LOCATOR(LOC_HOST, LOC_PORT)
chunks_on_each_worker <- 2
nworkers <- 3
dcsv_paths <- replicate(nworkers*chunks_on_each_worker, tempfile())
mapply(write.table,
       split(iris, rep(seq(nworkers*chunks_on_each_worker), each=nrow(iris)/(nworkers*chunks_on_each_worker))),
       dcsv_paths,
       MoreArgs=list(sep=',', row.names=F, col.names=F), SIMPLIFY=FALSE)
col.names <- colnames(iris)
colClasses <- vapply(iris, class, character(1), USE.NAMES=F)

diris <- read.dcsv(dcsv_paths, col.names=col.names, colClasses=colClasses)
dlm(Sepal.Width ~ Sepal.Length, diris)
