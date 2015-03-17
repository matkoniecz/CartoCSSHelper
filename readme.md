Proper testing of map rendering changes requires checking rendering for mutiple situations. Doing it manually requires preparing test data and/or locating places with applicable real data, loading map data into database, then moving viewport of TileMill to test data location and reviewing multiple zoom levels. It is process that is way too slow.

Fortunately it is possible to automate significant part of this workflow. With this tool testing new rendering change requires only specification of tag combination that should be tested and type of element.
It is work in progress, major problems that should be solved include:
* Lack of documentation
* It should be possible to install it as a ruby gem
* Executing git checkout commands on map style git repository during normal script operation (https://github.com/matkoniecz/CartoCSSHelper/issues/9)
* Current rendering method is obnoxiously slow. (https://github.com/matkoniecz/CartoCSSHelper/issues/1)

[![Code Climate](https://codeclimate.com/github/mkoniecz/CartoCSSHelper/badges/gpa.svg)](https://codeclimate.com/github/mkoniecz/CartoCSSHelper)