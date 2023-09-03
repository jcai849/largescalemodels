source("write_load.R")

iris$Species <- as.character(iris$Species)
diris <- write_load(iris)
liris <- largescaleobjects::emerge(diris)
dirislm <- dlm(Sepal.Width ~ Sepal.Length, diris)
lirislm <- largescaleobjects::emerge(dirislm, combiner=FALSE)[[1]]

library(biglm)
summary(lirislm)
gc()
