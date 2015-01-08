# encoding: UTF-8

require 'open3'

load 'tag_lister.rb'
load 'visualise_changes.rb'
load 'validator.rb'
load 'git.rb'
include Validator
include Git

def wrapper(main_key, main_value, variable_key, variable_key_values, type, branch_from, branch_to)
	tags = {main_key => main_value, 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000'}
	VisualDiff.visualise_changes(tags, type, false, Configuration.get_min_z..Configuration.get_max_z, branch_from, branch_to)
	variable_key_values.add('*')
	variable_key_values.each { |value|
		tags = {main_key => main_value, variable_key => value, 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000'}
		VisualDiff.visualise_changes(tags, type, false, Configuration.get_min_z..Configuration.get_max_z, branch_from, branch_to)
	}
end
def main
	#this code generates diff images for https://github.com/gravitystorm/openstreetmap-carto/pull/1191
	#new code resided on branch named 'private_transparent'
	#wrapper('leisure', 'playground', 'access', Set.new(['private', 'yes']), 'closed_way', 'master', 'private_transparent')
	#wrapper('amenity', 'recycling', 'access', Set.new(['private', 'yes']), 'closed_way', 'master', 'private_transparent')
	Git.switch_to_branch 'master'
	Git.init_commit_hash
	info = Info.new
	info.print_render_state_of_tags
	Validator.run_tests
end

main

