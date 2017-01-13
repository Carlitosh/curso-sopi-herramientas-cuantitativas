#!/bin/bash

for i in $(ls *.TIF)
do
    gdalwarp -overwrite -cutline ../roi.shp -crop_to_cutline -s_srs EPSG:32621
    -t_srs EPSG:32721 "$i" "crop$i"
    rm "$i"
    mv "crop$i" "$i"
done

gdalbuildvrt -separate pepe.vrt *.TIF


