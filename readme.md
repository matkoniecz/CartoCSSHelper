##CartoCSS Helper

It is a tool making development of CartoCSS styles more efficient.

Proper testing of map rendering requires testing covering mutiple situations. Doing it manually means preparing test data and locating places with applicable real data, loading map data into database, then moving viewport of TileMill to check every data location across multiple zoom levels. It is painfully slow.

Fortunately it is possible to automate it almost entirely. With this tool testing new rendering change requires only specification of tag combination that should be tested and type of element.

It is work in progress, major problems that should be solved include:

* Lack of documentation
* It should be possible to install it as a ruby gem
* Executing git checkout commands on map style git repository during normal script operation (https://github.com/matkoniecz/CartoCSSHelper/issues/9)
* Current rendering method is obnoxiously slow. (https://github.com/matkoniecz/CartoCSSHelper/issues/1)

###Example

`CartoCSSHelper.test ({'landuse' => 'village_green', 'tourism' => 'attraction'}), 'closed_way', 'master', 'v2.28.1'`

Runs quick test for specified tag combination rendering only this element, followed by locating multiple places across globe where such tags are used. For each test case images are produced both for current `master` branch and release `v2.28.1` across multiple zoom levels. Finally tool generates before/after comparisons for each case. Some of generated images were used in https://github.com/gravitystorm/openstreetmap-carto/issues/1371.

###Automated stuff

[![Code Climate](https://codeclimate.com/github/mkoniecz/CartoCSSHelper/badges/gpa.svg)](https://codeclimate.com/github/mkoniecz/CartoCSSHelper)
