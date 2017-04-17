library(raster)
library(rgdal)

# Ejemplo 1.3.1

ref.2016 <- brick("raster_data/LC82240782016304/LC82240782016304LGN00.vrt")
ref.2016

names(ref.2016) <- c("blue","green","red","nir","swir1","swir2")
ref.2016 <- ref.2016/1e4
rasterOptions(addheader = "ENVI")
writeRaster(ref.2016,"raster\_data/processed/ref2016")

plotRGB(ref.2016,r=4,g=5,b=3, stretch='lin')

# Ejemplo 1.3.2

summary(ref.2016)

hist(ref.2016)

pairs(ref.2016)

# Ejemplo 1.4.1
firmas <- readOGR(dsn="vector\_data/", layer="firmas")
firmas

plotRGB(ref.2016, stretch="lin")
plot(firmas,add=TRUE,col='red')

# Ejemplo 1.4.2
datos <- extract(ref.2016,firmas)
plot(ref.2016$red, ref.2016$nir)
points(as.data.frame(datos[1])$red, as.data.frame(datos[1])$nir,col="green",pch = ".")

# Ejemplo 1.4.3
promedio <- extract(ref.2016,firmas,fun=mean)
desvio <- extract(ref,firmas,fun=sd)

colnames(promedio) <- paster("mean",colnames("promedio"),sep="_")
colnames(desvio) <- paster("sd",colnames("desvio"),sep="_")

firmas@data <- cbind(firmas@data,promedio,desvio)
writeOGR(firmas, sdn="vector_data/processed","firmas_datos", driver="ESRI Shapefile")

# Ejemplo 1.4.4

library(reshape2)
library(lattice)

df <- t(promedio)
colnames(df) <- vector@data$Comment

df$wl <- as.matrix(c(485,560,660,830,1650,2215))
df <- melt(df,id.vars="wl", variable.name="cobertura")
names(df) <- c("wl","Cobertura","Reflectancia")

dfd <- t(desvio)
colnames(dfd) <- vector@data$Comment
dfd$wl <- as.matrix(c(485,560,660,830,1650,2215))
dfd <- melt("wl","Cobertura","Desvio")
df$desvio <- dfd$desvio
df$MC_ID <- as.character(vector@data$MC_ID[match(df$Cobertura,vector@data$Comment)])

xyplot(Reflectancia~wl, data=df, groups = Cobertura,
       auto.key=list(space="top", columns=4),
       ty=c("l", "p"))

xyplot(Reflectancia ~ wl | MC_ID, data=df, groups = Cobertura,
       auto.key=list(space="top", columns=4),
       ty=c("l", "p"))

xyplot(Reflectancia~wl | MC_ID, data=df, groups = Cobertura,
       auto.key=list(space="top", columns=4), ty=c("l", "p"),
       subset = Cobertura %in% c("Alto","Bajo"))