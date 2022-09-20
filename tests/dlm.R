source("write_load.R")

diris <- write_load(iris)
liris <- emerge(diris)
dirislm <- dlm(Sepal.Width ~ Sepal.Length, diris)
lirislm <- emerge(dirislm, combiner=FALSE)[[1]]
summary(lirislm)
gc()
