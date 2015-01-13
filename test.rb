# encoding: UTF-8

require 'open3'

load 'tag_lister.rb'
load 'visualise_changes_image_generation.rb'
load 'downloader.rb'
load 'data_file_handling.rb'
load 'validator.rb'
load 'git.rb'
include Validator
include Git

def wrapper_for_visual_diff(tags, variable_key, variable_key_values, type, branch_from, branch_to)
	if variable_key!= nil
		variable_key_values.add('*')
		variable_key_values.each { |value|
			tested_tags = tags.merge({variable_key => value, 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000'})
			VisualDiff.visualise_changes_synthethic_test(tested_tags, type, false, Configuration.get_min_z..Configuration.get_max_z, branch_from, branch_to)
		}
	end
	tested_tags = tags.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000'})
	VisualDiff.visualise_changes_synthethic_test(tested_tags, type, false, Configuration.get_min_z..Configuration.get_max_z, branch_from, branch_to)
end


def test_tag_on_real_data(tags, zlevels, old_branch, new_branch)
	krakow_latitude = 50.1
	krakow_longitude = 19.9
	VisualDiff.visualise_changes_on_real_data(tags, krakow_latitude, krakow_longitude, zlevels, old_branch, new_branch)
	japan_latitude = 36.1
	japan_longitude = 140.7
	VisualDiff.visualise_changes_on_real_data(tags, japan_latitude, japan_longitude, zlevels, old_branch, new_branch)
	russia_latitude = 54.8
	russia_longitude = 31.7
	VisualDiff.visualise_changes_on_real_data(tags, russia_latitude, russia_longitude, zlevels, old_branch, new_branch)
	mecca_latitude = 21.3
	mecca_longitude = 39.5
	VisualDiff.visualise_changes_on_real_data(tags, mecca_latitude, mecca_longitude, zlevels, old_branch, new_branch)
	georgia_latitude = 41.4
	georgia_longitude = 44.5
	VisualDiff.visualise_changes_on_real_data(tags, georgia_latitude, georgia_longitude, zlevels, old_branch, new_branch)
	london_latitude = 51.5
	london_longitude = -0.1
	VisualDiff.visualise_changes_on_real_data(tags, london_latitude, london_longitude, zlevels, old_branch, new_branch)
end

def test(tags, type, range, new_branch, old_brach='master')
	puts "processing #{VisualDiff.dict_to_pretty_tag_list(tags)}"
	wrapper_for_visual_diff(tags, nil, nil, type, old_brach, new_branch)
	test_tag_on_real_data(tags, range, old_brach, new_branch)
end

def main
=begin
	bare_land_range = 9..20
	test ({'natural' => 'bare_rock'}), 'closed_way', bare_land_range, 'bare-test', 'imagico/bare-landcover-patterns2'
	test ({'natural' => 'scree'}), 'closed_way', bare_land_range, 'bare-test', 'imagico/bare-landcover-patterns2'
	test ({'natural' => 'sand'}), 'closed_way', bare_land_range, 'bare-test', 'imagico/bare-landcover-patterns2'
	test ({'natural' => 'shingle'}), 'closed_way', bare_land_range, 'bare-test', 'imagico/bare-landcover-patterns2'

	test ({'access' => 'private', 'leisure' => 'playground'}), 'closed_way', 13..20, 'private_transparent'
	test ({'access' => 'private', 'amenity' => 'recycling'}), 'closed_way', 13..20, 'private_transparent'
=end
end

main