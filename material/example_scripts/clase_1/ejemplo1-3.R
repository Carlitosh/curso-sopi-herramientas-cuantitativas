# Ejemplo 1.3
# 2017-03-15
library(rgdal)

# Abrimos el vector
firmas <- readOGR(dsn = "vector_data/", layer = "firmas")
firmas

# Graficamos los poligonos
plotRGB(ref.2016, r=3, g=2, b=1, stretch="lin")
plot(firmas, add=TRUE, col="red")
