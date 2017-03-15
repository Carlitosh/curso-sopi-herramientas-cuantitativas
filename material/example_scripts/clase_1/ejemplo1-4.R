# Ejemplo 1.4
# 2017-03-15
library(rgdal)

# Extraemos los datos
datos <- extract(ref.2016, firmas)

# Scatterplot con un poligono resaltado
plot(ref.2016$red, ref.2016$nir)
points(as.data.frame(datos[1])$red, as.data.frame(datos[1])$nir, col="green", pch=".")
