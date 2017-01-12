library(raster)
library(RStoolbox)

# Abrimos la imagen landsat 8
xml.2015 <- readMeta("raster_data/LC82300772015071/LC82300772015071LGN00.xml")
ref.2015 <- stackMeta(xml.2015, quantity = "sre")
scaleF <- getMeta(ref.2015, xml.2015, what = "SCALE_FACTOR")
ref.2015 <- ref.2015 * scaleF
ref.2015 <- ref.2015[[-1,]]
names(ref.2015) <- c("blue","green","red","nir","swir1","swir2")

# Abrimos la imagen landsat 5
xml.1992 <- readMeta("raster_data/LT52300771992104/LT52300771992104CUB00.xml")
ref.1992 <- stackMeta(xml.1992, quantity = "sre")
scaleF <- getMeta(ref.1992, xml.2015, what = "SCALE_FACTOR")
ref.1992 <- ref.1992 * scaleF
names(ref.1992) <- c("blue","green","red","nir","swir1","swir2")

# Calculamos las transformadas por PCA de la imagen

pca.2015 <- rasterPCA(ref.2015)
summary(pca.2015$model)
loadings(pca.2015$model)
plot(pca.2015$map)

# PCA de apilado
delta <- stack(ref.2015, ref.1992)
names(delta) <- c("blue.2015","green.2015","red.2015","nir.2015","swir1.2015","swir2.2015",
                  "blue.1992","green.1992","red.1992","nir.1992","swir1.1992","swir2.1992")
plot(pca.delta$map,1:4)
