#!/bin/bash

for i in $(ls *.tif)
do
    print "$i"
    gdalwarp -cutline roi.shp -crop_to_cutline "$i" "roi-$i"
done

