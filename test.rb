# encoding: UTF-8

load 'validator.rb'
load 'tag_lister.rb'
load 'visualise_changes.rb'
load 'git.rb'
require 'open3'
include Validator

def main
	#visualise_changes({'man_made' => 'power_wind', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000'}, 'node', false, 4..22, 'master', 'deprecated')
	#visualise_changes({'amenity' => 'parking', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000'}, 'closed_way', false, 4..22, 'master', 'master')
	#visualise_changes({'amenity' => 'parking', 'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000'}, 'way', false, 4..22, 'master', 'master')
	switch_to_branch 'master'
	init_commit_hash
	info = Info.new
	info.print_render_state_of_tags
	Validator.run_tests
end

main

