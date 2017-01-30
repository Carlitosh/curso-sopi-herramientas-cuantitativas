## Correccion de imagenes

# Cargamos la libreria para manejo de rasters
library(raster)
library(RStoolbox)
library(ggplot2)

# Cargar imagen desde el metadato en reflectancia
xml.2000 <- readMeta("raster_data/LE72240782000188/LE72240782000188EDC00.xml")
ref.2000 <- stackMeta(xml.2000, quantity = "sre")

# Convertimos la imagens a reflecntacia
scaleF <- getMeta(ref.2000, xml.2000, what = "SCALE_FACTOR")
ref.2000 <- ref.2000 * scaleF

# Guardamos la imagen en reflectanciage
writeRaster(ref.2000,"raster_data/processed/ref2000")

# Cargamos la imagen desde el metadato
meta.2000 <- readMeta("raster_data/LE72240782000188EDC00/LE72240782000188EDC00_MTL.txt")
dn.2000 <- stackMeta(meta.2000)
# Guardamos solo las bandas reflectivas
dn.2000 <- dn.2000[[c(1:5,8)]]
# Calibramos a radiancias
# A mano
dn2rad <- meta.2000$CALRAD
dn2rad <- dn2rad[c(1:5,8),]
toa.2000 <- dn.2000*dn2rad$gain+dn2rad$offset

## Automatico
rad.2000 <- radCor(dn.2000, metaData = meta.2000, method="rad")
# Calibramos a reflectancia
toa.2000 <- radCor(dn.2000, metaData = meta.2000, method="apref")
# Correcciones por DOS
hist(toa.2000)
# Simple
haze.2000 <- estimateHaze(dn.2000,darkProp = 0.01, hazeBands = 1:4, plot=TRUE)
sdos.2000 <- radCor(dn.2000, metaData = meta.2000, hazeValues = haze.2000, hazeBands = c("B1_dn","B2_dn","B3_dn","B4_dn"), method="sdos")
# DOS
dos.2000 <- radCor(dn.2000, metaData = meta.2000, method="dos")
# COSTZ
cost.2000 <- radCor(dn.2000, metaData = meta.2000, method="costz")


## Guardar imagenes
# Agregamos el header de ENVI
rasterOptions(addheader = "ENVI")

writeRaster(l5_2011_rad,"raster_data/processed/rad2000")
writeRaster(l5_2011_toa,"raster_data/processed/toa2000")
writeRaster(l5_2011_sdos,"raster_data/processed/sdos2000")
writeRaster(l5_2011_dos,"raster_data/processed/dos2000")
writeRaster(l5_2011_costz,"raster_data/processed/cost2000")

