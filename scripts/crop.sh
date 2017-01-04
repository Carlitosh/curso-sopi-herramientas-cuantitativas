#!/bin/bash

for i in $(ls *.TIF)
do
    gdalwarp -overwrite -cutline ../material/imagenes/roi.shp -crop_to_cutline -s_srs EPSG:32620 -t_srs EPSG:32720 "$i" "crop$i"
    rm "$i"
    mv "crop$i" "$i"
done

gdalbuildvrt -separate pepe.vrt *.TIF


