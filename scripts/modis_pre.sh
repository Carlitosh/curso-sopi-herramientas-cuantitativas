#!/bin/bash

# Listo las imagenes .hdf
# http://pymodis.fem-environment.eu/


for imagen in $(ls -1 -d *.hdf); do
    # Recorto el nombre y le saco el .hdf
    Nimagen="${imagen%.hdf}"

    # Convierto a geotiff y reproyecto
    modis_convert.py -s "( 1 0 )" -o "UTM21s-NDVI-$Nimagen" -g 250 -e 32721  $imagen
    modis_convert.py -s "( 0 1 )" -o "UTM21s-EVI-$Nimagen" -g 250 -e 32721  $imagen
done

