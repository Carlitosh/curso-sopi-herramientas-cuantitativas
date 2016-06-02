#!/bin/bash

for i in $(ls *.st)
do
    gdalwarp -cutline ../roi.shp -crop_to_cutline -t_srs EPSG:32721 "$i" "utm21s-roi-$i"
done

