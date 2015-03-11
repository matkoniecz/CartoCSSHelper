load 'CartoCSSHelper.rb'
include CartoCSSHelper

def main
  CartoCSSHelper::Configuration.set_path_to_tilemill_project_folder(File.join(ENV['HOME'], 'Documents', 'MapBox', 'project', 'osm-carto', ''))

  #visualises railway=station nearby given location
  #VisualDiff.visualise_changes_on_real_data({'railway' => 'station'}, 53.4090, 14.4363, 3..20, 'master', 'master')

  #https://github.com/gravitystorm/openstreetmap-carto/pull/1341
  #todo - why calling naked functions is OK?
  #check_dy('leisure', 'golf_course', 22, true)
  #check_dy('leisure', 'miniature_golf', 22, true)

  #https://github.com/gravitystorm/openstreetmap-carto/pull/1242
  #CartoCSSHelper::VisualDiff.visualise_changes_on_real_data({'natural' => 'wetland'}, 49.69745, 20.28088, 13..20, 'master', 'pnorman/random_forest')
  #CartoCSSHelper.test ({'landuse' => 'forest', 'natural' => 'wetland'}), 'closed_way', 3..20, 'pnorman/random_forest'
  #CartoCSSHelper.test ({'landuse' => 'forest'}), 'closed_way', 3..20, 'pnorman/random_forest'
  #CartoCSSHelper.test ({'natural' => 'wood'}), 'closed_way', 3..20, 'pnorman/random_forest'
  #neither blocking nor merging

  #https://github.com/gravitystorm/openstreetmap-carto/pull/1249
  #CartoCSSHelper.test ({'amenity' => 'bench'}), 'node', 3..20, 'math/bench-waste'
  #CartoCSSHelper.test ({'amenity' => 'waste_basket'}), 'node', 3..20, 'math/bench-waste'
  #author pinged

  #https://github.com/gravitystorm/openstreetmap-carto/pull/1274
  #CartoCSSHelper.test ({'tourism' => 'zoo'}), 'closed_way', 3..20, 'math/zoo'

  CartoCSSHelper.probe ({'amenity' => 'bicycle_parking'}), 'closed_way', 3..20, 'bicycle-parking'
  CartoCSSHelper.probe ({'amenity' => 'parking'}), 'closed_way', 3..20, 'bicycle-parking'
  CartoCSSHelper.probe ({'amenity' => 'bicycle_parking'}), 'node', 3..20, 'bicycle-parking'
  CartoCSSHelper.probe ({'amenity' => 'parking'}), 'node', 3..20, 'bicycle-parking'
  CartoCSSHelper::Git.checkout('bicycle-parking')
  check_dy('amenity', 'bicycle_parking', 22, true)

  #https://github.com/gravitystorm/openstreetmap-carto/pull/1361
  CartoCSSHelper.test ({'amenity' => 'bicycle_parking'}), 'closed_way', 3..20, 'bicycle-parking', 'math/bicycle-parking'
  CartoCSSHelper.test ({'amenity' => 'parking'}), 'closed_way', 3..20, 'bicycle-parking', 'math/bicycle-parking'
  CartoCSSHelper.test ({'amenity' => 'bicycle_parking', 'access'=>'private'}), 'closed_way', 3..20, 'bicycle-parking', 'math/bicycle-parking'
  CartoCSSHelper.test ({'amenity' => 'parking', 'access'=>'private'}), 'closed_way', 3..20, 'bicycle-parking', 'math/bicycle-parking'

  CartoCSSHelper.test ({'amenity' => 'bicycle_parking'}), 'closed_way', 3..20, 'math/bicycle-parking'
  CartoCSSHelper.test ({'amenity' => 'bicycle_parking'}), 'node', 3..20, 'math/bicycle-parking'

  CartoCSSHelper.test ({'amenity' => 'parking'}), 'closed_way', 3..20, 'master'
  CartoCSSHelper.test ({'amenity' => 'parking'}), 'node', 3..20, 'master'
  #CartoCSSHelper::Validator.run_closed_way_test('v2.28.1')
  CartoCSSHelper::Validator.run_expected_rendering_test('v2.28.1')
  #CartoCSSHelper::Validator.run_tests('v2.28.1')
  #info.print_render_state_of_tags('v2.28.1')
end

main