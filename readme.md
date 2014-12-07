I created this set of tools as I consider using TileMill and checking of random features on a generated map for entirety of testing as inadequate and leading to testing on production.

It is proof of concept and work in progress - there are still major problems, including but not limited to:
* Executing git checkout commands on map style git repository during normal script operation
* Current rendering method is obnoxiously slow. Using https://github.com/gravitystorm/mapnik-legendary would be preferable, but it relies on https://github.com/mapnik/Ruby-Mapnik that is currently broken (see bugs https://github.com/mapnik/Ruby-Mapnik/issues/47 and https://github.com/mapnik/Ruby-Mapnik/issues/48).
* Hardcoded location of map style and scrip (file config.rb)
* It is unknown whatever it will be usable for CartoCSS projects other than https://github.com/gravitystorm/openstreetmap-carto

[![Code Climate](https://codeclimate.com/github/mkoniecz/CartoCSSHelper/badges/gpa.svg)](https://codeclimate.com/github/mkoniecz/CartoCSSHelper)