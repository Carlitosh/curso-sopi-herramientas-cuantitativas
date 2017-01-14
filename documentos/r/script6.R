library(caret)
library(randomForest)
library(e1071)
library(RStoolbox)
library(rgdal)
library(raster)



# Abrimos la imagen landsat 8
xml.2015 <- readMeta("raster_data/LC82300772015071/LC82300772015071LGN00.xml")
ref.2015 <- stackMeta(xml.2015, quantity = "sre")
scaleF <- getMeta(ref.2015, xml.2015, what = "SCALE_FACTOR")
ref.2015 <- ref.2015 * scaleF
ref.2015 <- ref.2015[[-1,]]
names(ref.2015) <- c("blue","green","red","nir","swir1","swir2")

# Clasificacion no supervisada
rasterOptions(addheader = "ENVI")
set.seed(6)
uc.2016 <- unsuperClass(ref.2015, nClasses = 6, nStarts = 100, nSamples = 10000)
writeRaster(uc.2016$map,"raster_data/processed/uc2016", datatype = "INT1U")


# Grafico las clases por separado
classes <- layerize(uc.2016$map)
plot(classes)

# substituyo valores
df <- data.frame(id=1:5,v=c(1,1,1,2,2))
x <- subs(uc.2016$map, df)

# filtro 3x3
# Definimos el nucleo de 3x3 unitario
window <- matrix(1,nrow=15, ncol=15)
filter.2016<-focal(uc.2016$map,w=window,fun=modal)

# Clasificacion supervisada
vector <- readOGR(dsn="vector_data/", layer="entrenamiento")
valid <- readOGR(dsn="vector_data/", layer="validacion")
# inspeccionar elemento
vector

# qqplot contra normal
extract(ref.2015,vector, fun=qqnorm)

sup.2016 <- superClass(ref.2015, vector, responseCol = "MC_ID", model = "mlc")
sup.2016b <- superClass(ref.2015, vector, responseCol = "MC_ID", model = "rf")
validation <- validateMap(sup.2016$map,valData = valid, responseCol = "MC_ID")
validationb <- validateMap(sup.2016b$map,valData = valid, responseCol = "MC_ID")
