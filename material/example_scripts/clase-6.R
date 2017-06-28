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
vector <- readOGR(dsn="vector_data", layer="entrenamiento")

# Basica
library(e1071)
colores = c('#b2df8a','#33a02c',
            '#fdbf6f','#ff7f00',
            '#fb9a99','#e31a1c',
            '#a6cee3','#1f78b4')
sup.2016 <- superClass(ref.2016, vector, responseCol = "MC_ID", model = "mlc")
plot(sup.2016$map, col=colores, zlim=c(1,8))

# Ejemplo 6.1.1
sup.2016b <- superClass(ref.2016, vector, responseCol = "C_ID", model = "mlc")

subs.2016 = vector@data[c(3,1)]
sub.2016 <- reclassify(sup.2016b$map, subs.2016)
writeRaster(sub.2016, "raster_data/processed/mlc2016.tif",datatype="INT1U")

plot(stack(sup.2016$map,sub.2016),col=colores,zlim=c(1,8))

# Ejemplo 6.2.1

set.seed(42)
library(e1071)
sup.2016 <- superClass(ref.2016, vector, responseCol = "C_ID", model = "mlc")
mlc.2016 <- reclassify(sup.2016$map, subs.2016)

library(randomForest)
sup.2016 <- superClass(ref.2016, vector, responseCol = "C_ID",model = "rf")
rf.2016 <- reclassify(sup.2016$map, subs.2016)

library(kernlab)
sup.2016 <- superClass(ref.2016, vector, responseCol = "C_ID", model = "svmLinear")
svm.2016 <- reclassify(sup.2016$map, subs.2016)

prediction_stack <- stack(mlc.2016, rf.2016, svm.2016)
names(prediction_stack) <- c("mlc","rf","svm")
model_entropy <- rasterEntropy(prediction_stack)

plot(stack(prediction_stack, model_entropy),col=colores)
