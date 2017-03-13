## Manejo raster

# Cargamos la libreria para manejo de rasters
library(raster)
library(RStoolbox)
library(ggplot2)
library(rasterVis)
library(reshape2)
# Apertura de una banda
red.2016 <- raster("raster_data/LC82240782016304/LC82240782016304LGN00_sr_band4.tif")
nir.2016 <- raster("raster_data/LC82240782016304/LC82240782016304LGN00_sr_band5.tif")

# Apertura de un raster multibanda
ref.2016 <- brick("raster_data/LC82240782016304/LC82240782016304LGN00.vrt")

# Apertura de varios raster como stack, no stackeamos la banda 6
bandas.2016 <- list.files("raster_data/LC82240782016304/", pattern = "*[2-7]+.tif$", full.names = TRUE)
ref.2016 <- stack(bandas.2016)
# Convertimos a reflectancia
ref.2016 <- ref.2016/1e4
# Inspeccionar elemento
ref.2016

# Cambiar nombres
nombres <- c("blue","green","red","nir","swir1","swir2")
names(ref.2016) <- nombres
ref.2016

# Mas informacion sobre el elemento
summary(ref.2016)
extent(ref.2016)

# Grafico de una banda
ggR(ref.2016,layer = "nir", geom_raster = TRUE)+scale_fill_gradientn(colours=rainbow(100))

# Grafico combinacion de bandas
ggRGB(ref.2016,r="nir", g="red", b="blue", geom_raster = TRUE, stretch = "lin")

# Grafico el histograma de una banda
hist(ref.2016$nir)

# Histograma de todas las bandasa
hist(ref.2016)

# Si se queda en 3*2
par( mfrow = c( 1, 1 ) )
# Scatterplot de dos bandas
plot(ref.2016$red, ref.2016$nir)


# Todos los scatterplots e histogramas (toma su tiempo)
pairs(ref.2016)

## Manejo vectorial
library(rgdal)

# Apertura de shapefile
vector <- readOGR(dsn="vector_data/", layer="firmas")

# inspeccionar elemento
vector

# Graficar raster y vector
poligono <- fortify(vector)
ggRGB(ref.2016,r="nir", g="red", b="blue", geom_raster = TRUE, stretch = "lin")+
  geom_path(data=poligono, aes(x=long,y=lat,group=id),col="green")+
  coord_equal()


# Extraer informacion de un vector
datos <- extract(ref.2016,vector)

# Plotear los datos en un scatterplot
plot(ref.2016$red, ref.2016$nir)
points(as.data.frame(datos[1])$red,as.data.frame(datos[1])$nir, col="green")
points(as.data.frame(datos[2])$red,as.data.frame(datos[2])$nir, col="red")

# Extraer datos
promedio <- extract(ref.2016, vector, fun=mean)
colnames(promedio) <- paste("mean", colnames(promedio), sep = "_")

desvio <- extract(ref.2016,vector, fun=sd)
colnames(desvio) <- paste("sd", colnames(desvio), sep = "_")

# Guardar datos en el vector
vector@data <- cbind(vector@data, promedio, desvio)
writeOGR(vector, dsn="vector_data/processed/", "datos", driver="ESRI Shapefile")

# Graficar las firmas espectrales con su desvio standar

#Convertir en data frame
df <- t(promedio)
colnames(df) <- vector@data$Comment
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
df$Desvio <- dfd$Desvio
df$MC_ID <- as.character(vector@data$MC_ID[match(df$Cobertura, vector@data$Comment)])

require(lattice)

xyplot(Reflectancia + (Reflectancia+Desvio) + (Reflectancia-Desvio) ~ wl, data = df, subset = Cobertura %in% c("Alto","Bajo"), type="")
