library(caret)
library(randomForest)
library(e1071)
library(RStoolbox)
library(rgdal)
library(raster)
library(rasterVis)
library(kernlab)


# Abrimos la imagen landsat 8
xml.2016 <- readMeta("raster_data/LC82240782016304/LC82240782016304LGN00.xml")
ref.2016 <- stackMeta(xml.2016, quantity = "sre")
scaleF <- getMeta(ref.2016, xml.2016, what = "SCALE_FACTOR")
ref.2016 <- ref.2016 * scaleF
ref.2016 <- ref.2016[[-1,]]
names(ref.2016) <- c("blue","green","red","nir","swir1","swir2")

# Clasificacion supervisada
vector <- readOGR(dsn="vector_data/", layer="entrenamiento")
valid <- readOGR(dsn="vector_data/", layer="validacion")
# inspeccionar elemento
vector

# qqplot contra normal
#extract(ref.2016,vector, fun=qqnorm)

sup.2016 <- superClass(ref.2016, vector, responseCol = "MC_ID", model = "rf")
validation <- validateMap(sup.2016$map,valData = valid, responseCol = "MC_ID")
validation
plot(sup.2016$map, col = rainbow(8))
