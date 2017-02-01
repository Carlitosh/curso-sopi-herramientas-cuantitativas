library(RStoolbox)
library(rgdal)
library(raster)
library(rasterVis)


# Abrimos la imagen landsat 8
xml.2016 <- readMeta("raster_data/LC82240782016304/LC82240782016304LGN00.xml")
ref.2016 <- stackMeta(xml.2016, quantity = "sre")
scaleF <- getMeta(ref.2016, xml.2016, what = "SCALE_FACTOR")
ref.2016 <- ref.2016 * scaleF
ref.2016 <- ref.2016[[-1,]]
names(ref.2016) <- c("blue","green","red","nir","swir1","swir2")

# Clasificacion no supervisada
rasterOptions(addheader = "ENVI")
set.seed(6)
kmeans.2016 <- unsuperClass(ref.2016, nClasses = 5, nStarts = 100, nSamples = 10000)
writeRaster(kmeans.2016$map,"raster_data/processed/kmeans2016", datatype = "INT1U", overwrite=TRUE)


# Grafico las clases por separado
classes <- layerize(kmeans.2016$map)
plot(classes)

# substituyo valores
clases.2016 <- read.delim("class")
reclas.2016 <- subs(kmeans.2016$map, clases.2016)

# filtro 3x3
# Definimos el nucleo de 3x3 unitario
window <- matrix(1,nrow=5, ncol=5)
filter.2016<-focal(reclas.2016,w=window,fun=modal)

# Ploteo un scatterplot clasificado
apilado <- stack(ref.2016,kmeans.2016$map)
xyplot(nir~red, groups=layer, data=apilado)
