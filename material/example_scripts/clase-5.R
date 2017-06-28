library(raster)
library(RStoolbox)
library(rasterVis)
library(rgdal)

# Imagen
rasterOptions(addheader = "ENVI")
xml.2016 <- readMeta("raster_data/LC82240782016304/LC82240782016304LGN00.xml")
ref.2016 <- stackMeta(xml.2016, quantity = "sre")
scaleF <- getMeta(ref.2016,xml.2016, what = "SCALE_FACTOR")
ref.2016 <- ref.2016 * scaleF
ref.2016 <- ref.2016[[-1,]]
names(ref.2016) <- c("blue","green","red","nir","swir1","swir2")

# Ejemplo 5.1.1
set.seed(42)
kmeans.2016 <- unsuperClass(ref.2016, nClasses = 5, nStarts = 100,
                            nSamples = 100)
writeRaster(kmeans.2016$map, "raster_data/processed/kmeans2016.tif",datatype="INT1U")

clases.2016 <- layerize(kmeans.2016$map)
plot(clases.2016)

clases.2016 <- read.delim("aux_data/class.txt")
reclas.2016 <- subs(kmeans.2016$map, clases.2016)

colores = c('#b2df8a','#33a02c',
            '#fdbf6f','#ff7f00',
            '#fb9a99','#e31a1c',
            '#a6cee3','#1f78b4')
plot(reclas.2016, col=colores, zlim=c(1,8))

# Ejemplo 5.1.2
stack.2016 <- stack(ref.2016, reclas.2016)
xyplot(nir+swir1~red, groups=MC_ID, data=stack.2016)

# Ejemplo 5.1.3
set.seed(42)
kmeans.2016b <- unsuperClass(ref.2016, nClasses = 100, nStarts = 100,
                            nSamples = 1000)
writeRaster(kmeans.2016b$map, "raster_data/processed/kmeans2016b.tif",datatype="INT1U", overwrite=TRUE)
clasesb.2016 <- read.delim("aux_data/class100.txt")
reclasb.2016 <- subs(kmeans.2016b$map, clasesb.2016)
plot(reclasb.2016, col=colores, zlim=c(1,8))

stackb.2016 <- stack(ref.2016, reclasb.2016)
xyplot(nir+swir1~red, groups=MC_ID, data=stack.2016)
xyplot(nir+swir1~red, groups=MC_ID, data=stackb.2016)

# Ejemplo 5.2.1
pan.2016 <- raster("raster_data/LC82240782016304LGN00/LC82240782016304LGN00_B8.TIF")
window <- matrix(1,nrow=5, ncol=5)
sd.2016<-focal(pan.2016,w=window,fun=sd)
plot(log(sd.2016,base = 10), zlim=c(1,4))

sd.2016 <- aggregate(sd.2016, fact=2, fun=mean)
stack(ref.2016, sd.2016)
pca.2016 <- rasterPCA(stack(ref.2016, sd.2016), spca = TRUE)

# Ejemplo 5.2.2
list.2016 <- list.files("raster_data/MOD13Q1/NDVI/", pattern = "MOD13Q1.A2016+.*tif", full.names = TRUE)
ndvi.2016 <- stack(list.2016)/1e4
ndvi.2016 <- approxNA(ndvi.2016)
sd.2016 <- calc(ndvi.2016, fun = sd)
me.2016 <- calc(ndvi.2016, fun = mean)
plot(stack(me.2016,sd.2016))

sd.2016 <- resample(sd.2016, ref.2016, method="ngb")
me.2016 <- resample(me.2016, ref.2016, method="ngb")
pca.2016 <- rasterPCA(stack(ref.2016, me.2016, sd.2016), spca = TRUE)
summary(pca.2016$model)
