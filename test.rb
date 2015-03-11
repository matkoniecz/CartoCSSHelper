load 'CartoCSSHelper.rb'
include CartoCSSHelper

def main
  CartoCSSHelper::Configuration.set_path_to_tilemill_project_folder(File.join(ENV['HOME'], 'Documents', 'MapBox', 'project', 'osm-carto', ''))

  #https://github.com/gravitystorm/openstreetmap-carto/pull/1242
  #CartoCSSHelper::VisualDiff.visualise_changes_on_real_data({'natural' => 'wetland'}, 49.69745, 20.28088, 13..20, 'master', 'pnorman/random_forest')
  #CartoCSSHelper.test ({'landuse' => 'forest', 'natural' => 'wetland'}), 'closed_way', 3..20, 'pnorman/random_forest'
  #CartoCSSHelper.test ({'landuse' => 'forest'}), 'closed_way', 3..20, 'pnorman/random_forest'
  #CartoCSSHelper.test ({'natural' => 'wood'}), 'closed_way', 3..20, 'pnorman/random_forest'

  #https://github.com/gravitystorm/openstreetmap-carto/pull/1350
  CartoCSSHelper.test ({'tourism' => 'path'}), 'way', 3..20, 'math/path-background-opacity'
  CartoCSSHelper.test ({'highway' => 'path'}), 'closed_way', 3..20, 'math/path-background-opacity'

  #https://github.com/gravitystorm/openstreetmap-carto/pull/1274
  CartoCSSHelper.test ({'tourism' => 'zoo'}), 'closed_way', 3..20, 'math/zoo'

  #https://github.com/gravitystorm/openstreetmap-carto/pull/1345
  CartoCSSHelper.test ({'highway' => 'pedestrian', 'area' => 'yes', 'name' => :any_value}), 'closed_way', 3..20, 'math/minzoom-road-area'
  CartoCSSHelper.test ({'highway' => 'footway', 'area' => 'yes', 'name' => :any_value}), 'closed_way', 3..20, 'math/minzoom-road-area'

  #https://github.com/gravitystorm/openstreetmap-carto/pull/1317
  CartoCSSHelper.test ({'highway' => 'construction', 'construction' => 'footway', 'name' => :any_value}), 'way', 3..20, 'math/construction-path-width'
  CartoCSSHelper.test ({'highway' => 'construction', 'construction' => 'footway'}), 'way', 3..20, 'math/construction-path-width'
  CartoCSSHelper.test ({'highway' => 'construction', 'construction' => 'cycleway'}), 'way', 3..20, 'math/construction-path-width'
  CartoCSSHelper.test ({'highway' => 'construction', 'construction' => 'bridleway'}), 'way', 3..20, 'math/construction-path-width'
  CartoCSSHelper.test ({'highway' => 'construction', 'construction' => 'path'}), 'way', 3..20, 'math/construction-path-width'
  CartoCSSHelper.test ({'highway' => 'construction', 'construction' => 'track'}), 'way', 3..20, 'math/construction-path-width'
  info = Info.new

  CartoCSSHelper::Validator.run_tests('v2.28.1')
  info.print_render_state_of_tags('v2.28.1')
end

main