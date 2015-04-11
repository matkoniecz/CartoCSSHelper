##CartoCSS Helper

It is a tool making development of CartoCSS styles more efficient. Automates actions necessary to produce test images and validates style. Allows to write simple Ruby scripts that generate comparison images and validation reports. Loading data using osm2pgsql, rendering with TileMill, obtaining test data from overpass turbo.

Proper testing of map rendering requires testing covering mutiple situations. Doing it manually means preparing test data and locating places with applicable real data, loading map data into database, then moving viewport of TileMill to check every data location across multiple zoom levels. It is painfully slow.

Fortunately it is possible to automate it almost entirely. With this tool testing new rendering change requires only specification of tag combination that should be tested and type of element.

It is work in progress, major problems that should be solved include:

* Improving documentation
* Executing git checkout commands on map style git repository during normal script operation (https://github.com/matkoniecz/CartoCSSHelper/issues/9)
* Current rendering method is obnoxiously slow. (https://github.com/matkoniecz/CartoCSSHelper/issues/1)

###Installation

Assumes that osm2pgsql and TileMill are installed.

This tool is available as cartocss_helper Ruby gem.

Install ruby - see https://www.ruby-lang.org/en/documentation/installation/ for details.

Unfortunately, standard `gem install cartocss_helper` may not be enough as CartoCSS Helper depends on RMagick gem that requires special installation.

Install RMagick gem. `gem install rmagick` may not be enough - in my case, on Ubuntu 14.04 it was necessary to start from installing additional packages (`apt-get install ruby-dev imagemagick libmagickcore-dev libmagickwand-dev` solved the problem), followed by `gem install rmagick`.

Finally, run `gem install cartocss_helper`.

###Example

It is assumed that TileMill project with Default OSM Style (https://github.com/gravitystorm/openstreetmap-carto/) is located at `~/Documents/MapBox/project/osm-carto`.

    require cartocss_helper
    CartoCSSHelper::Configuration.set_style_specific_data(CartoCSSHelper::StyleDataForDefaultOSM.get_style_data)
    CartoCSSHelper::Configuration.set_path_to_tilemill_project_folder(File.join(ENV['HOME'], 'Documents', 'MapBox', 'project', 'osm-carto', ''))
    CartoCSSHelper::Configuration.set_path_to_folder_for_output(File.join(ENV['HOME'], 'Documents', 'CartoCSSHelper-output', ''))
    CartoCSSHelper::Configuration.set_path_to_folder_for_cache(File.join(ENV['HOME'], 'Documents', 'CartoCSSHelper-tmp', ''))

    tags = {'landuse' => 'village_green', 'tourism' => 'attraction'}
    CartoCSSHelper.test tags, 'master', 'v2.28.1'

First part of this Ruby script is responsible for loading gem and configuration, including location of cache folder and folder where produced comparison images will be saved.

Second part runs quick test for specified tag combination rendering only this element as node, way and a closed way. It is followed by locating multiple places across globe where such tag combination is used.

For each test case images are produced both for current `master` branch and release `v2.28.1` across multiple zoom levels. Finally tool generates before/after comparisons for each case. Some of generated images were used in https://github.com/gravitystorm/openstreetmap-carto/issues/1371.

It is also possible to look for certain keys, with any value:

    tags = {'landuse' => 'village_green', 'tourism' => 'attraction', 'name' => :any_value}
    CartoCSSHelper.test tags, 'master', 'v2.28.1'


###Automated stuff

[![Code Climate](https://codeclimate.com/github/mkoniecz/CartoCSSHelper/badges/gpa.svg)](https://codeclimate.com/github/mkoniecz/CartoCSSHelper)
