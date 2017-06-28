# Cargamos la libreria para manejo de rasters
library(raster)
library(rasterVis)
library(RStoolbox)
library(bfastSpatial)
library(greenbrown)
cols <- colorRampPalette(brewer.pal(9,"YlGn"))

# Cargamos las bandas de modis
evi.bands <- list.files("raster_data/MOD13Q1/EVI/", pattern = "*.tif$", full.names = TRUE)
evi.stack <- timeStackMODIS(evi.bands)

#names(evi.stack) <- ndvi.stack@z$time

levelplot(evi.stack, layers = 1:4,col.regions=cols)

# Lleno los NA
evi.aprox <- approxNA(evi.stack)

# Convertimos la imagen a numeros entre -1 y 1
evi.aprox <- evi.aprox/1e4
evi.aprox@z <- evi.stack@z


evi.pca <- rasterPCA(evi.aprox)

writeRaster(evi.aprox, "raster_data/aprox",format="ENVI")

trend.evi <- TrendRaster(evi.aprox, start=c(2000,3), freq = 23)
