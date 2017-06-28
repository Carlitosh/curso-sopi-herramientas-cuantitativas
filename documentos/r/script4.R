library(raster)
library(RStoolbox)
library(bfastSpatial)
library(rts)
# Abrimos la imagen landsat 8
xml.2016 <- readMeta("raster_data/LC82240782016304/LC82240782016304LGN00.xml")
ref.2016 <- stackMeta(xml.2016, quantity = "sre")
scaleF <- getMeta(ref.2016, xml.2016, what = "SCALE_FACTOR")
ref.2016 <- ref.2016 * scaleF
ref.2016 <- ref.2016[[-1,]]
names(ref.2016) <- c("blue","green","red","nir","swir1","swir2")

# Abrimos la imagen landsat 5
xml.2000 <- readMeta("raster_data/LE72240782000188/LE72240782000188EDC00.xml")
ref.2000 <- stackMeta(xml.2000, quantity = "sre")
scaleF <- getMeta(ref.2000, xml.2016, what = "SCALE_FACTOR")
ref.2000 <- ref.2000 * scaleF
names(ref.2000) <- c("blue","green","red","nir","swir1","swir2")

# Calculamos las transformadas por PCA de la imagen

pca.2016 <- rasterPCA(ref.2016)
summary(pca.2016$model)
loadings(pca.2016$model)
plot(pca.2016$map)

# PCA de apilado
delta <- stack(ref.2016, ref.2000)
names(delta) <- c("blue.2016","green.2016","red.2016","nir.2016","swir1.2016","swir2.2016",
                  "blue.2000","green.2000","red.2000","nir.2000","swir1.2000","swir2.2000")
pca.delta <- rasterPCA(delta)
plot(pca.delta$map,1:4)
# Serie temporal
ndvi.list <- list.files("raster_data/MOD13Q1/NDVI/", pattern = "*.tif$", full.names = TRUE)
ndvi.stack <- stack(ndvi.list)
ndvi.stack <- ndvi.stack/1e4
ndvi.stack <- approxNA(ndvi.stack)
# Interpolamos los valores faltantes 
fechas <- strptime(as.numeric(gsub(".NDVI","",gsub("MOD13Q1.A",replacement = "",names(ndvi.stack))))/1e3,"%Y.%j")
fechas <- as.POSIXct(fechas)

# Creamos el objeto temporal
ndvi.time <- rts(ndvi.stack, fechas)

# Analizamos el promedio y el desvio por año
ndvi.mean <- apply.yearly(ndvi.time, FUN=mean)
ndvi.sd <- apply.yearly(ndvi.time, FUN=sd)

# Analizamos la serie temporal en un pixel
p5000 <- extract(ndvi.time, y=5000)
plot(p5000)

# Analizamos el PCA
ndvi.pca <- rasterPCA(ndvi.stack)
plot(ndvi.pca$map,1:4)

# Transformacion por TSC
tsa.2016 <- tasseledCap(ref.2016,sat="Landsat8OLI")
names(tsa.2016) <- c("Brigthness","Greenness","Wetness")

