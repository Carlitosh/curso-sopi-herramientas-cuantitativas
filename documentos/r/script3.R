library(raster)
library(RStoolbox)
library(landsat)
library(RColorBrewer)
library(rgdal)
library(ggplot2)
library(GGally)


# Abrimos la imagen landsat 8
xml.2016 <- readMeta("raster_data/LC82240782016304/LC82240782016304LGN00.xml")
ref.2016 <- stackMeta(xml.2016, quantity = "sre")
scaleF <- getMeta(ref.2016, xml.2016, what = "SCALE_FACTOR")
ref.2016 <- ref.2016 * scaleF
ref.2016 <- ref.2016[[-1,]]
names(ref.2016) <- c("blue","green","red","nir","swir1","swir2")


# Calculamos el ndvi a mano y lo graficamos
ndvi.2016 <- (ref.2016$nir-ref.2016$red)/(ref.2016$nir+ref.2016$red)
cols <- colorRampPalette(brewer.pal(9,"YlGn"))(16)
plot(ndvi.2016, col=cols, zlim=c(0,1))

# Calculamos el ndvi con el paquete RStoolbox
ndvi.2016 <- spectralIndices(ref.2016, red="red", nir="nir", indices="NDVI")

# Calculemos ahora el evi y el ndvi
ndvi_evi.2016 <- spectralIndices(ref.2016, blue="blue",red="red", nir="nir", indices=c("NDVI","EVI"))
par( mfrow = c( 1, 1 ) )
plot(ndvi_evi.2016,col=cols, zlim=c(0,1))

# Y calculamos todos los posibles
indices.2016 <- spectralIndices(ref.2016, red="red", nir="nir")
plot(indices.2016,col=cols, zlim=c(0,1))

# Calculo del tSAVI
# Enmascaramos la imagen
mask.2016 <- raster("raster_data/LC82240782016304/LC82240782016304LGN00_cfmask.tif")
plot(mask.2016)
masked.2016 <- mask(ref.2016, mask=mask.2016, inverse=TRUE, maskvalue=0, updatevalue=255)
masked.2016[masked.2016<=0] <- 255
bsl.2016 <- BSL(as.matrix(masked.2016$red), as.matrix(masked.2016$nir),method="quantile", ulimit=0.99, llimit=0.001)

plot(ref.2016$red, ref.2016$nir)
abline(bsl.2016$BSL, col="red")

# Calculamos el tSAVI a mano
b <- bsl.2016$BSL['Intercept']
m <- bsl.2016$BSL['Slope']
tSAVI.2016 <- m*(ref.2016$nir-m*ref.2016$red-b)/(m*ref.2016$nir+ref.2016$red-m*b)
plot(tSAVI.2016,col=cols)


### MIRAR!!!!
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
