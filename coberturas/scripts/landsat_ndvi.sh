#!/bin/bash

for i in $(ls utm*)
do
	gdal_calc.py -A "$i" --A_band=3 -B "$i" --B_band=4 --calc="10000*(B.astype(float)-A.astype(float))/(B.astype(float)+A.astype(float))" --type="Int16" --format="GTiff" --outfile="ndvi-$i"
done

