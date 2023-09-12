init_test <- local({
	inited <- FALSE
	function() {
		if (!inited) {
			LOC_HOST <- "localhost"
			LOC_PORT <- 9000L

			orcv::start()
			chunknet::LOCATOR(LOC_HOST, LOC_PORT)
			inited <<- TRUE
		}
	}
})

write_load_test_matrix <- function(x) {
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
	write_load_matrix <- function(dataset) {
		dwrite_table(as.data.frame(dataset), '|')
		largescaleobjects::read.dmatrix(file_paths, ddim=c(N, 1))
	}

	init_test()

	chunks_on_each_worker <- 2
	nworkers <- 3
	N <- nworkers*chunks_on_each_worker
	file_paths <- replicate(nworkers*chunks_on_each_worker, tempfile())

	write_load_matrix(x)
}

getAb <- local({
	x <- NULL
	function() {
		if (is.null(x)) {
			m <- 20
			n <- 500000
			N <- 5
			A <- matrix(runif(m*n), n, m)
			A[,1] <- 1
			x_actual <- matrix(0, m)
			x_actual[c(1, 3, 14, 15, 9),] <- c(27, 1, 8, 2, 82)
			b <- A %*% x_actual

			x <<- lapply(list(A,b), write_load_test_matrix)

		}
		x
	}
})
