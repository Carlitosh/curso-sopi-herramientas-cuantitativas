library(raster)
library(RStoolbox)

# Abrimos la imagen landsat 8
xml.2015 <- readMeta("raster_data/LC82240782016304/LC82240782016304LGN00.xml")
ref.2015 <- stackMeta(xml.2015, quantity = "sre")
scaleF <- getMeta(ref.2015, xml.2015, what = "SCALE_FACTOR")
ref.2015 <- ref.2015 * scaleF
ref.2015 <- ref.2015[[-1,]]
names(ref.2015) <- c("blue","green","red","nir","swir1","swir2")

# Cargamos la banda pancromatica
pan.2001 <- raster("raster_data/LE72240782000188EDC00/LE72240782000188EDC00_B8.TIF")

# Calculamos el ndvi con el paquete RStoolbox
ndvi.2015 <- spectralIndices(ref.2015, red="red", nir="nir", indices="NDVI")

# Analisis de varianza
# Definimos el nucleo de 3x3 unitario
window <- matrix(1,nrow=3, ncol=3)
var.ndvi.2015r<-focal(ndvi.2015,w=window,fun=var)
