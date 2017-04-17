library(raster)
library(RStoolbox)
library(rasterVis)

# Ejemplo 7.1.1.
mlc.2016 = raster("raster_data/processed/mlc2016")

colores = c('#b2df8a','#33a02c',
            '#fdbf6f','#ff7f00',
            '#fb9a99','#e31a1c',
            '#a6cee3','#1f78b4')
window <- matrix(1,nrow=3, ncol=3)
mlc.3x3.2016 <-focal(mlc.2016,w=window,fun=modal)
writeRaster(mlc.3x3.2016,"raster_data/processed/mlc3x3-2016", datatype = "INT1U", overwrite=TRUE)
plot(mlc.3x3.2016,col=colores)

plot(stack(mlc.2016, mlc.3x3.2016),col=colores)

# Ejemplo 7.2.1

freq.2016 <- freq(mlc.3x3.2016)

freq.2016[,2] <- round(freq.2016[,2]/sum(freq.2016[,2])*250+50)

# Ejemplo 7.2.2

valid.2016 <- readOGR(dsn="vector_data", layer="validacion")
val.2016 <- validateMap(mlc.3x3.2016,valData = valid.2016,
                          responseCol = "MC_ID")

val.2016$performance
