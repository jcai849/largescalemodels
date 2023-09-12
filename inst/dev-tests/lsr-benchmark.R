library(largescaleobjects)
library(largescalemodelr)

N <- 20

orcv::start()
init_locator("localhost", 9000L)
mapply(init_worker, "localhost", seq(9001L, length.out=N))

dates <- format(seq(as.Date("2011-01-01"), length.out=N, by="month"), "%Y-%m")
paths <- paste0("/data/nyctaxi/csv/yellow_tripdata_", dates, ".csv.bz2")
Sys.sleep(3)

taxis <- do.dcall(function(path) {
        cols <- c("vendor_id"="character",
            "pickup_datetime"="POSIXct",
            "dropoff_datetime"="POSIXct",
            "passenger_count"="integer",
            "trip_distance"="numeric",
            "pickup_longitude"="numeric",
            "pickup_latitude"="numeric",
            "rate_code"="integer",
            "store_and_fwd_flag"="character",
            "dropoff_longitude"="numeric",
            "dropoff_latitude"="numeric",
            "payment_type"="character",
            "fare_amount"="numeric",
            "surcharge"="numeric",
            "mta_tax"="numeric",
            "tip_amount"="numeric",
            "tolls_amount"="numeric",
            "total_amount"="numeric")
        iotools::read.csv.raw(bzfile(path), colClasses=as.vector(cols), skip=1L)
    }, list(dpath(paths)))

X <- d(as.matrix)(taxis[,c("passenger_count", "trip_distance", "fare_amount", "surcharge", "mta_tax", "tolls_amount")])
y <- taxis$tip_amount

gc()

timing <- system.time(X_hat <- dlasso(X, y, tolerance=1, rho=3, lambda=3))

sink(paste0("dlasso-benchmark-",uuid::UUIDgenerate()))
print(timing)
sink()

chunknet::kill_all_nodes()
q("no")