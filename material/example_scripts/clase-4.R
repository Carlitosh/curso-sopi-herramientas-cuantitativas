library(raster)
library(RStoolbox)
library(rgdal)
library(rasterVis)

# Imagen
xml.2016 <- readMeta("raster_data/LC82240782016304/LC82240782016304LGN00.xml")
ref.2016 <- stackMeta(xml.2016, quantity = "sre")
scaleF <- getMeta(ref.2016,xml.2016, what = "SCALE_FACTOR")
ref.2016 <- ref.2016 * scaleF
ref.2016 <- ref.2016[[-1,]]
names(ref.2016) <- c("blue","green","red","nir","swir1","swir2")

# Ejemplo 4.1.1
B1 <- xyplot(nir~red,data=ref.2016)
B2 <- xyplot(red~green,data=ref.2016)
print(B1,split=c(1,1,2,1),more=TRUE)
print(B2,split=c(2,1,2,1),more=FALSE)

tsc.2016 <- tasseledCap(ref.2016,sat="Landsat8OLI")

plotRGB(tsc.2016,r=1,g=2,b=3, stretch="lin")

# Ejemplo 4.2.1
pairs(ref.2016)

pca.2016 <- rasterPCA(ref.2016)
summary(pca.2016$model)

loadings(pca.2016\$model)

# Ejemplo 4.3.1
ndvi.list <- list.files("raster_data/MOD13Q1/NDVI/", pattern = "*.tif$",
                         full.names = TRUE)
ndvi.stack <- stack(ndvi.list)

ndvi.stack <- ndvi.stack/1e4
ndvi.stack <- approxNA(ndvi.stack)
writeRaster(ndvi.stack,"ndvi-series.tif")

ndvi.mean <- mean(ndvi.stack)
plot(ndvi.mean)
ndvi.sd <- calc(ndvi.stack, fun=sd)
plot(ndvi.sd)
