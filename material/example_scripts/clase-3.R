library(raster)
library(RStoolbox)
library(rgdal)
library(rasterVis)
library(RColorBrewer)
library(landsat)

# Imagen
xml.2016 <- readMeta("raster_data/LC82240782016304/LC82240782016304LGN00.xml")
ref.2016 <- stackMeta(xml.2016, quantity = "sre")
scaleF <- getMeta(ref.2016,xml.2016, what = "SCALE_FACTOR")
ref.2016 <- ref.2016 * scaleF
ref.2016 <- ref.2016[[-1,]]
names(ref.2016) <- c("blue","green","red","nir","swir1","swir2")

# Ejemplo 3.1.1
ndvi.2016 <- (ref.2016$nir-ref.2016$red)/(ref.2016$nir+ref.2016$red)
cols = colorRampPalette(brewer.pal(9,"YlGn"))(256)
plot(ndvi.2016, col=cols, zlim = c(0,1))

# Ejemplo 3.1.2
indices.2016 <- spectralIndices(ref.2016,
                                blue="blue", red="red", nir="nir",
                                indices=c("NDVI","EVI"))
plot(indices.2016,col=cols, zlim=c(0,1))

# Ejemplo 3.2.1
mask.2016 <- raster("raster_data/LC82240782016304/LC82240782016304LGN00_cfmask.tif")
masked.2016 <- mask(ref.2016, mask=mask.2016, inverse=TRUE,
                    maskvalue=0, updatevalue=255)
masked.2016[masked.2016<=0] <- 255

bsl.2016 <- BSL(as.matrix(masked.2016$red), as.matrix(masked.2016$nir),
                method="quantile")
plot(ref.2016$red, ref.2016$nir)
abline(bsl.2016$BSL,col="red")

bsl.2016

# Ejemplo 3.3.1
vector <- readOGR(dsn="vector_data/", layer="muestreo")
datos <- extract(ndvi.2016,vector)
DF <- data.frame(vector@data,datos)

lm.2016 <- lm(fcover~ndvi, data=muestreo)
plot(muestreo$ndvi, mustreo$fcover)
abline(lm.2016, col="red")
summary(lm.2016)
pairs(DF)

fcover.2016 <- predict(ndvi.2016,lm.2016)
plot(fcover.2016)
