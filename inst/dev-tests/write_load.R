library(largescalemodels)

LOC_HOST <- "localhost"
LOC_PORT <- 9000L

orcv::start()
chunknet::LOCATOR(LOC_HOST, LOC_PORT)
chunks_on_each_worker <- 2
nworkers <- 3
N <- nworkers*chunks_on_each_worker
file_paths <- replicate(nworkers*chunks_on_each_worker, tempfile())

dwrite_table <- function(dataset, sep) {
	chunk_groups <- seq(N)
	nobs <- floor(nrow(dataset)/(N))
	first_chunk_map <- rep(chunk_groups[-length(chunk_groups)], each=nobs)
	last_chunk_map <- rep(chunk_groups[length(chunk_groups)], NROW(dataset)-length(first_chunk_map))
	chunk_map <-  c(first_chunk_map, last_chunk_map)
	mapply(write.table,
	       split(dataset, chunk_map),
	       file_paths,
	       MoreArgs=list(sep=sep, row.names=F, col.names=F), SIMPLIFY=FALSE)
}

write_load <- function(dataset) {
	dwrite_table(dataset, ',')
	colClasses <- vapply(dataset, class, character(1), USE.NAMES=T)
	largescaleobjects::read.dcsv(file_paths, colClasses=colClasses)
}

write_load_matrix <- function(dataset) {
	dwrite_table(as.data.frame(dataset), '|')
	largescaleobjects::read.dmatrix(file_paths, ddim=c(N, 1))
}

wl <- function(...) {for (d in list(...)) write_load(d)}
