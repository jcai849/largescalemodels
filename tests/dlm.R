source("write_load.R")

iris$Species <- as.character(iris$Species)
diris <- write_load(iris)
liris <- largescaler::emerge(diris)
dirislm <- dlm(Sepal.Width ~ Sepal.Length, diris)
lirislm <- largescaler::emerge(dirislm, combiner=FALSE)[[1]]
summary(lirislm)
gc()
