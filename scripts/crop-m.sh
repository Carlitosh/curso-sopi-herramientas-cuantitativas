#!/bin/bash

for i in $(ls *.hdf); do
    modis_convert.py -s "(1 0)" -o "$i" -g 250 -e 32721 $i
done

rename "s/h13v11.006.*.hdf_250m 16 days NDVI\./NDVI\./g" *.tif

for i in $(ls *NDVI.tif); do
    gdalwarp -overwrite -cutline ../roi.shp -crop_to_cutline "$i" "crop$i"
    rm "$i"
    mv "crop$i" "$i"
done

for i in $(ls *.hdf); do
    modis_convert.py -s "(0 1 0)" -o "$i" -g 250 -e 32721 $i
done

rename "s/h13v11.006.*.hdf_250m 16 days EVI\./EVI\./g" *.tif

for i in $(ls *EVI.tif); do
    gdalwarp -overwrite -cutline ../roi.shp -crop_to_cutline "$i" "crop$i"
    rm "$i"
    mv "crop$i" "$i"
done




