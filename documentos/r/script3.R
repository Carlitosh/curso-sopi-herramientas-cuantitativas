library(raster)
library(RStoolbox)
library(landsat)
library(RColorBrewer)
library(rgdal)
library(ggplot2)
library(GGally)


# Abrimos la imagen landsat 8
xml.2015 <- readMeta("raster_data/LC82300772015071/LC82300772015071LGN00.xml")
ref.2015 <- stackMeta(xml.2015, quantity = "sre")
scaleF <- getMeta(ref.2015, xml.2015, what = "SCALE_FACTOR")
ref.2015 <- ref.2015 * scaleF
ref.2015 <- ref.2015[[-1,]]
names(ref.2015) <- c("blue","green","red","nir","swir1","swir2")


# Calculamos el ndvi a mano y lo graficamos
ndvi.2015 <- (ref.2015$nir-ref.2015$red)/(ref.2015$nir+ref.2015$red)
cols <- colorRampPalette(brewer.pal(9,"YlGn"))(16)
plot(ndvi.2015, col=cols, zlim=c(0,1))

# Calculamos el ndvi con el paquete RStoolbox
ndvi.2015b <- spectralIndices(ref.2015, red="red", nir="nir", indices="NDVI")

# Calculemos ahora el evi y el ndvi
ndvi_evi.2015 <- spectralIndices(ref.2015, blue="blue",red="red", nir="nir", indices=c("NDVI","EVI"))
plot(ndvi_evi.2015,col=cols, zlim=c(0,1))

# Y calculamos todos los posibles
indices.2015 <- spectralIndices(ref.2015, red="red", nir="nir")
plot(indices.2015,col=cols, zlim=c(0,1))

# Calculo del tSAVI
# Enmascaramos la imagen
mask.2015 <- raster("raster_data/LC82300772015071/LC82300772015071LGN00_cfmask.tif")
plot(mask.2015)
masked.2015 <- mask(ref.2015, mask=mask.2015, inverse=TRUE, maskvalue=0, updatevalue=255)
masked.2015[masked.2015<=0] <- 255
bsl.2015 <- BSL(as.matrix(masked.2015$red), as.matrix(masked.2015$nir),method="quantile", ulimit=0.99, llimit=0.001)

plot(ref.2015$red, ref.2015$nir)
abline(bsl.2015$BSL, col="red")

# Calculamos el tSAVI a mano
m <- bsl.2015$BSL['Intercept']
b <- bsl.2015$BSL['Slope']
tSAVI.2015 <- m*(ref.2015$nir-m*ref.2015$red-b)/(m*ref.2015$nir+ref.2015$red-m*b)

# Ajuste de indice vs datos de campo
# Analisis de los datos
vector <- readOGR(dsn="vector_data/", layer="sampled")
datos <- extract(ndvi_evi.2015,vector)
DF <- data.frame(vector@data,datos)
ggpairs(DF[,-1],diag=list(continuous="barDiag"))

# Ajuste segun un modelo y lo grafico plot.
lmf.2015 <- lm(SR ~ I(1/(NDVI-1)),DF)
DF$newSR <- predict.lm(lmf.2015)

# Grafico el modelo
ggplot(data=DF, aes(x=NDVI,y=SR))+geom_point()+geom_smooth(aes(x=NDVI,y=newSR))

# Aplico el modelo a una imagen y lo grafico
newSR.2015 <- predict(ndvi.2015,lmf.2015)
ggR(newSR.2015, geom_raster = TRUE)+
  geom_point(data=vector.df,aes(x=coords.x1,y=coords.x2,colour=SR),size=5)+
  scale_fill_gradientn(colours=cols)+
  scale_colour_gradientn(colours=cols,guide = "none")+coord_equal()
