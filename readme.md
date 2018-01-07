## CartoCSS Helper

It is a tool making development of CartoCSS styles more efficient. Allows to write simple Ruby scripts that generate comparison images of how rendering changed between two versions of map style. It is also possible to generate validation reports detecting for example too low values of text-dy. Loading data using osm2pgsql, rendering with TileMill, obtaining test data from overpass turbo.

Proper testing of map rendering requires testing covering mutiple situations. Doing it manually means preparing test data and locating places with applicable real data, loading map data into database, then moving viewport of TileMill to check every data location across multiple zoom levels. It is painfully slow.

Fortunately it is possible to automate it almost entirely. With this tool testing new rendering change requires only specification of tag combination that should be tested and type of element.

It is work in progress, major problems that should be solved include:

* Improving documentation
* Executing git checkout commands on map style git repository during normal script operation (https://github.com/matkoniecz/CartoCSSHelper/issues/9)
* Current rendering method is obnoxiously slow. (https://github.com/matkoniecz/CartoCSSHelper/issues/1)

### Installation

Assumes that osm2pgsql and TileMill are installed.

This tool is available as cartocss_helper Ruby gem.

Install ruby - see https://www.ruby-lang.org/en/documentation/installation/ for details.

Unfortunately, standard `gem install cartocss_helper` may not be enough as CartoCSS Helper depends on RMagick gem that requires special installation.

1. install software necessary to install RMagick gem. On Lubuntu 14.04 it was enough to run `sudo apt-get install ruby-dev imagemagick libmagickcore-dev libmagickwand-dev`.
2. `gem install --user-install rmagick`
3. `gem install --user-install cartocss_helper`.

### Examples

It is assumed that CartoCSS project with Default OSM Style (https://github.com/gravitystorm/openstreetmap-carto/) is located at `~/Documents/MapBox/project/osm-carto`.

    require 'cartocss_helper'

    CartoCSSHelper::Configuration.set_style_specific_data(CartoCSSHelper::StyleDataForDefaultOSM.get_style_data)
    project_location = File.join(ENV['HOME'], 'Documents', 'MapBox', 'project', 'osm-carto', '')
    CartoCSSHelper::Configuration.set_path_to_cartocss_project_folder(project_location)
    output_folder = File.join(ENV['HOME'], 'Documents', 'CartoCSSHelper-output', '')
    CartoCSSHelper::Configuration.set_path_to_folder_for_output(output_folder)
    cache_folder = File.join(ENV['HOME'], 'Documents', 'CartoCSSHelper-tmp', '')
    CartoCSSHelper::Configuration.set_path_to_folder_for_cache(cache_folder)

    tags = {'landuse' => 'village_green', 'tourism' => 'attraction'}
    CartoCSSHelper.test tags, 'master', 'v2.28.1'

or, to just test on real examples of landuse=quarry tagged on ways (most will form areas)

    require 'cartocss_helper'

    CartoCSSHelper::Configuration.set_style_specific_data(CartoCSSHelper::StyleDataForDefaultOSM.get_style_data)
    project_location = File.join(ENV['HOME'], 'Documents', 'MapBox', 'project', 'osm-carto', '')
    CartoCSSHelper::Configuration.set_path_to_cartocss_project_folder(project_location)
    output_folder = File.join(ENV['HOME'], 'Documents', 'CartoCSSHelper-output', '')
    CartoCSSHelper::Configuration.set_path_to_folder_for_output(output_folder)
    cache_folder = File.join(ENV['HOME'], 'Documents', 'CartoCSSHelper-tmp', '')
    CartoCSSHelper::Configuration.set_path_to_folder_for_cache(cache_folder)

    tags = {'landuse' => 'quarry'}
    branch_name = 'quarry-icon'
    base_branch_name = 'master'
    zlevels = 10..22
    type = 'way' #or 'node'
    test_locations_count = 10
    CartoCSSHelper.test_tag_on_real_data_for_this_type(tags, branch_name, base_branch_name, zlevels, type, test_locations_count)

First part of this Ruby script is responsible for loading gem and configuration, including location of cache folder and folder where produced comparison images will be saved.

Second part runs quick test for specified tag combination rendering only this element as node, way and a closed way. It is followed by locating multiple places across globe where such tag combination is used.

For each test case images are produced both for current `master` branch and release `v2.28.1` across multiple zoom levels. Finally tool generates before/after comparisons for each case. Some of generated images were used in https://github.com/gravitystorm/openstreetmap-carto/issues/1371.

It is also possible to look for certain keys, with any value:

    tags = {'landuse' => 'village_green', 'tourism' => 'attraction', 'name' => :any_value}
    CartoCSSHelper.test tags, 'master', 'v2.28.1'

### Tests

Tests are written using rspec. Use `rspec` command to run them.

### Automated stuff

[![Code Climate](https://codeclimate.com/github/matkoniecz/CartoCSSHelper/badges/gpa.svg)](https://codeclimate.com/github/matkoniecz/CartoCSSHelper)
[![Build Status](https://travis-ci.org/matkoniecz/CartoCSSHelper.svg?branch=master)](https://travis-ci.org/matkoniecz/CartoCSSHelper)