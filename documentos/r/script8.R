library(caret)
library(randomForest)
library(e1071)
library(kernlab)
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

# Clasificacion supervisada
vector <- readOGR(dsn="vector_data/", layer="entrenamiento")
valid <- readOGR(dsn="vector_data/", layer="validacion")
# inspeccionar elemento
vector

# qqplot contra normal
#extract(ref.2016,vector, fun=qqnorm)

sup.2016b <- superClass(ref.2016, vector, responseCol = "MC_ID", model = "mlc")
validation <- validateMap(sup.2016$map,valData = valid, responseCol = "MC_ID")
validation
plot(sup.2016$map, col = rainbow(8))

sup.2016 <- superClass(ref.2016, vector, responseCol = "C_ID", model = "mlc")
sup.2016$map <- subs(sup.2016$map , vector@data[c(3,1)])
sup.2016$map <- subs(sup.2016$map , sup.2016b$classMapping)
validation <- validateMap(sup.2016$map,valData = valid, responseCol = "MC_ID")
validation
plot(sup.2016$map, col = rainbow(8))

sup.2016 <- superClass(ref.2016, vector, responseCol = "C_ID", model = "rf")
sup.2016$map <- subs(sup.2016$map , vector@data[c(3,1)])
sup.2016$map <- subs(sup.2016$map , sup.2016b$classMapping)
validation <- validateMap(sup.2016$map,valData = valid, responseCol = "MC_ID")
validation
plot(sup.2016$map, col = rainbow(8))

# Calculo de entropia
modelos <- c("rf","mlc","svmRadial","svmLinear")
  
ensemble <- lapply(modelos, function(mod){
  set.seed(5)
  sc <- superClass(ref.2016, trainData = vector,
                   responseCol = "MC_ID", model=mod)
  return(sc$map)
})  

prediction_stack <- stack(ensemble)
names(prediction_stack) <- modelos

model_entropy <- rasterEntropy(prediction_stack)
