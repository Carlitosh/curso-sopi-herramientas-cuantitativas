# Ejemplo 1.1
# 2017-03-15
# Cargamos las bibliotecas para trabajar
library(raster)

# Abrimos la imagen como brick
ref.2016 <- brick("raster_data/LC82240782016304/LC82240782016304LGN00.vrt")
# Propiedades de la imagen
ref.2016

# Cambiamos los nombres
names(ref.2016) <- c("blue","green","red","nir","swir1","swir2")

# Convertimos a valores entre 0 y 1
ref.2016 <- ref.2016/1e4

# Guardamos la imagen
rasterOptions(addheader = "ENVI")
writeRaster(ref.2016,"raster_data/processed/ref2016")