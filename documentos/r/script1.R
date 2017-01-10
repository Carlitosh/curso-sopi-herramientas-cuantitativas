i\## Manejo raster

# Cargamos la libreria para manejo de rasters
library(raster)
library(RStoolbox)
library(ggplot2)

# Apertura de una banda
l5_2011_b3 <- raster("raster_data/LT52280792011078/LT52280792011078CUB00_sr_band3.tif")
l5_2011_b4 <- raster("raster_data/LT52280792011078/LT52280792011078CUB00_sr_band4.tif")

# Apertura de un raster multibanda
l5_2011_brick <- brick("raster_data/LT52280792011078/LT52280792011078CUB00.vrt")

# Apertura de varios raster como stack, no stackeamos la banda 6
l5_2011_bands <- list.files("raster_data/LT52280792011078/", pattern = "*[1-7]+.tif$", full.names = TRUE)
l5_2011 <- stack(l5_2011_bands)
# Convertimos a 
l5_2011 <- l5_2011/1e4
# Inspeccionar elemento
l5_2011

# Cambiar nombres
nombres <- c("blue","green","red","nir","swir1","swir2")
names(l5_2011) <- nombres
l5_2011

# Mas informacion sobre el elemento
l5_2011
summary(l5_2011)
extent(l5_2011)

# Grafico de una banda
ggR(l5_2011,layer = "nir", geom_raster = TRUE)+scale_fill_gradientn(colours=rainbow(100))

# Grafico combinacion de bandas
ggRGB(l5_2011,r="nir", g="red", b="blue", geom_raster = TRUE, stretch = "lin")

# Grafico el histograma de una banda
hist(l5_2011$nir)

# Histograma de todas las bandasa
hist(l5_2011)

# Si se queda en 3*2
par( mfrow = c( 1, 1 ) )
# Scatterplot de dos bandas
plot(l5_2011$red, l5_2011$nir)


# Todos los scatterplots e histogramas (toma su tiempo)
pairs(l5_2011)

## Manejo vectorial
library(rgdal)

# Apertura de shapefile
vector <- readOGR(dsn="vector_data/", layer="extract")

# inspeccionar elemento
vector

# Graficar raster y vector
poligono <- fortify(vector)
ggRGB(l5_2011,r="nir", g="red", b="blue", geom_raster = TRUE, stretch = "lin")+
  geom_path(data=poligono, aes(x=long,y=lat,group=id),col="green")+
  coord_equal()


# Extraer informacion de un vector
datos <- extract(l5_2011,vector)

# Plotear los datos en un scatterplot
plot(l5_2011$red, l5_2011$nir)
points(as.data.frame(datos[1])$red,as.data.frame(datos[1])$nir, col="green")
points(as.data.frame(datos[2])$red,as.data.frame(datos[2])$nir, col="red")

# Extraer datos
promedio <- extract(l5_2011,vector, fun=mean)
colnames(promedio) <- paste("mean", colnames(promedio), sep = "_")

desvio <- extract(l5_2011,vector, fun=sd)
colnames(desvio) <- paste("sd", colnames(desvio), sep = "_")

# Guardar datos en el vector
vector@data <- cbind(vector@data, promedio, desvio)
writeOGR(vector, dsn="vector_data/processed/", "datos", driver="ESRI Shapefile")

# Graficar las firmas espectrales con su desvio standar

#Convertir en data frame
df <- t(promedio)
colnames(df) <- vector@data$descripcio
df <- as.data.frame(df)
df$wl <- as.matrix(c(485,560,660,830,1650,2215))
df <- melt(df ,  id.vars = 'wl', variable.name = 'Cobertura')
names(df) <- c("wl","Cobertura","Reflectancia")

dfd <- t(desvio)
colnames(dfd) <- vector@data$descripcio
dfd <- as.data.frame(dfd)
dfd$wl <- as.matrix(c(485,560,660,830,1650,2215))
dfd <- melt(dfd ,  id.vars = 'wl', variable.name = 'Cobertura')
names(dfd) <- c("wl","Cobertura","Desvio")

# Agregar el desvio
df$desvio <- dfd$Desvio

# Graficar
ggplot(df, aes(wl,Reflectancia))+
  geom_line(aes(colour = Cobertura))+
  geom_point(aes(colour = Cobertura))+
  geom_errorbar(aes(ymin=Reflectancia-2*desvio, ymax=Reflectancia+2*desvio), width=.1)
