#!/bin/bash

set -e -u -o pipefail

TMP="$(dirname $0)/tmp"
mkdir -p $TMPmapb
PWD=$(pwd)

if [ $(echo "\d" | psql -U postgres census | grep census_tracts2010 | wc -l) != "0" ]; then
    echo "+ census_tracts2010 (noop)"
    exit 0
fi

for CODE in '01' '02' '04' '05' '06' '08' '09' '10' '11' '12' '13' '15' '16' '17' '18' '19' '20' '21' '22' '23' '24' '25' '26' '27' '28' '29' \
  '30' '31' '32' '33' '34' '35' '36' '37' '38' '39' '40' '41' '42' '44' '45' '46' '47' '49' '50' '51' '53' '54' '55' '56' '60' '66' '69' '72' '78'
do
  echo "Downloading tract CODE:${CODE}"
  curl -f -o $TMP/tract-${CODE}.zip http://www2.census.gov/geo/tiger/TIGER2010/TRACT/2010/tl_2010_${CODE}_tract10.zip
  unzip -d $TMP $TMP/tract-${CODE}.zip
  echo "COPYING tl_2010_${CODE}_tract10.shp"
  ogr2ogr -append -t_srs EPSG:3857 -f "PostgreSQL" -nlt PROMOTE_TO_MULTI -nln census_tracts2010 PG:"host=localhost user=postgres dbname=census" $TMP/tl_2010_${CODE}_tract10.shp
done

echo "
    ALTER TABLE census_tracts2010 RENAME wkb_geometry TO geom;
    CREATE INDEX census_tracts2010_gist ON census_tracts2010 USING GIST (geom);
" | psql -U postgres census
