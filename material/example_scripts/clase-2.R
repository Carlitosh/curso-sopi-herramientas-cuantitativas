library(raster)
library(RStoolbox)
library(rasterVis)

# Ejemplo 2.1.1
meta.2000 <- readMeta("raster_data/LE72240782000188EDC00/LE72240782000188EDC00_MTL.txt")

meta.2000$SOLAR_PARAMETERS

dn.2000 <- stackMeta(meta.2000)
dn.2000 <- dn.2000[[-6:-7,]]
dn.2000

plotRGB(dn.2000, r=3, g=2, b=1, stretch="lin")

# Ejemplo 2.1.2

dn2ref.2000 <- meta.2000$CALREF[1:6,]
elev.2000 <- pi*meta.2000$SOLAR_PARAMETERS['elevation']/180

toam.2000 <- (dn.2000*dn2ref.2000$gain+dn2ref.2000$offset)/sin(elev.2000)
names(toam.2000) <- c("blue","green","red","nir","swir1","swir2")

toa.2000 <- radCor(dn.2000, metaData = meta.2000, method = "apref")

# Ejemplo 2.2.1

haze.2000 <- estimateHaze(dn.2000,darkProp = 0.01, hazeBands = 1:4, plot=TRUE)
sdos.2000 <- radCor(dn.2000, metaData = meta.2000,
             hazeValues = haze.2000,
             hazeBands = c("B1_dn","B2_dn","B3_dn","B4_dn"),
             method="sdos")

sdos.2000

B1 <- densityplot(~B1_tre+B1_sre, data=toa.boa, xlab="Reflectancia",
                  ylab="", main="Banda azul", plot.points=FALSE, xlim=c(0,0.3),
                  key=simpleKey(text=c("Tope de la atmosfera",
                                       "Correccion Simple DOS"),
                                       lines=TRUE, points=FALSE))
B2 <- densityplot(~B2_tre+B2_sre, data=toa.boa, xlab="Reflectancia",
                  ylab="", main="Banda verde", plot.points=FALSE, xlim=c(0,0.3),
                  key=simpleKey(text=c("Tope de la atmosfera",
                                       "Correccion Simple DOS"),
                                       lines=TRUE, points=FALSE))
B3 <- densityplot(~B3_tre+B3_sre, data=toa.boa, xlab="Reflectancia",
                  ylab="", main="Banda roja", plot.points=FALSE, xlim=c(0,0.3),
                  key=simpleKey(text=c("Tope de la atmosfera",
                                       "Correccion Simple DOS"),
                                       lines=TRUE, points=FALSE))
B4 <- densityplot(~B4_tre+B4_sre, data=toa.boa, xlab="Reflectancia",
                  ylab="", main="Banda nir", plot.points=FALSE, xlim=c(0,0.3),
                  key=simpleKey(text=c("Tope de la atmosfera",
                                       "Correccion Simple DOS"),
                                       lines=TRUE, points=FALSE))
 print(B1,split = c(1, 1, 2, 2),more=TRUE)
 print(B2,split = c(2, 1, 2, 2),more=TRUE)
 print(B3,split = c(1, 2, 2, 2),more=TRUE)
 print(B4,split = c(2, 2, 2, 2),more=FALSE)
