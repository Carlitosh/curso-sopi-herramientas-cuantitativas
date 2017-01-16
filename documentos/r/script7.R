# Cargamos la libreria para manejo de rasters
library(raster)
library(rasterVis)
library(RStoolbox)
library(bfastSpatial)

cols <- colorRampPalette(brewer.pal(9,"YlGn"))

# Cargamos las bandas de modis
ndvi.bands <- list.files("raster_data/MOD13Q1/EVI/", pattern = "*.tif$", full.names = TRUE)
ndvi.stack <- timeStackMODIS(ndvi.bands)

names(ndvi.stack) <- ndvi.stack@z$time

levelplot(ndvi.stack, layers = 1:4,col.regions=cols)