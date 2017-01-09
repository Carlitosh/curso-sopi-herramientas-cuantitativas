## Correccion de imagenes

# Cargamos la libreria para manejo de rasters
library(raster)
library(RStoolbox)
library(ggplot2)

# Cargar imagen desde el metadato en reflectancia
xml_meta2011 <- readMeta("raster_data/LT52280792011078/LT52280792011078CUB00.xml")
l5_2011_cdr <- stackMeta(xml_meta2011, quantity = "sre")

# Convertimos la imagens a reflecntacia
scaleF <- getMeta(l5_2011_cdr, xml_meta2011, what = "SCALE_FACTOR")
l5_2011_cdr <- l5_2011_cdr * scaleF

# Guardamos la imagen en reflectancia
writeRaster(l5_2011_cdr,"raster_data/processed/l5_2011_cdr")

# Cargamos la imagen desde el metadato
meta2011 <- readMeta("raster_data/LT52280792011078CUB00/LT52280792011078CUB00_MTL.txt")
l5_2011 <- stackMeta(meta2011)
# Guardamos solo las bandas reflectivas
l5_2011 <- l5_2011[[c((1:5),7)]]
# Calibramos a radiancias
# A mano
dn2rad <- meta2011$CALRAD
dn2rad <- dn2rad[-6,]
l5_2011_rad <- l5_2011*dn2rad$gain+dn2rad$offset

## Automatico
l5_2011_rad <- radCor(l5_2011, metaData = meta2011, method="rad")
# Calibramos a reflectancia
l5_2011_toa <- radCor(l5_2011, metaData = meta2011, method="apref")
# Correcciones por DOS
hist(l5_2011)
# Simple
haze <- estimateHaze(l5_2011,darkProp = 0.01, hazeBands = 1:4, plot=TRUE)
l5_2011_sdos <- radCor(l5_2011, metaData = meta2011, hazeValues = haze, hazeBands = c("B1_dn","B2_dn","B3_dn","B4_dn"), method="sdos")
# DOS
l5_2011_dos <- radCor(l5_2011, metaData = meta2011, method="dos")
# COSTZ
l5_2011_costz <- radCor(l5_2011, metaData = meta2011, method="costz")


## Guardar imagenes
# Agregamos el header de ENVI
rasterOptions(addheader = "ENVI")
writeRaster(l5_2011_rad,"raster_data/processed/l5_2011_rad")
writeRaster(l5_2011_toa,"raster_data/processed/l5_2011_toa")
writeRaster(l5_2011_sdos,"raster_data/processed/l5_2011_sdos")
writeRaster(l5_2011_dos,"raster_data/processed/l5_2011_dos")
writeRaster(l5_2011_costz,"raster_data/processed/l5_2011_costz")

