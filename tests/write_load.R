library(largescalemodelr)

LOC_HOST <- "localhost"
LOC_PORT <- 9000L

orcv::start()
chunknet::LOCATOR(LOC_HOST, LOC_PORT)
chunks_on_each_worker <- 2
nworkers <- 3
dcsv_paths <- replicate(nworkers*chunks_on_each_worker, tempfile())

write_load <- function(dataset) {
	chunk_groups <- seq(nworkers*chunks_on_each_worker)
	nobs <- floor(nrow(dataset)/(nworkers*chunks_on_each_worker))
	first_chunk_map <- rep(chunk_groups[-length(chunk_groups)], each=nobs)
	last_chunk_map <- rep(chunk_groups[length(chunk_groups)], NROW(dataset)-length(first_chunk_map))
	chunk_map <-  c(first_chunk_map, last_chunk_map)
	mapply(write.table,
	       split(dataset, chunk_map),
	       dcsv_paths,
	       MoreArgs=list(sep=',', row.names=F, col.names=F), SIMPLIFY=FALSE)
	colClasses <- vapply(dataset, class, character(1), USE.NAMES=T)
	dataset <- largescaler::read.dcsv(dcsv_paths, colClasses=colClasses)
}
