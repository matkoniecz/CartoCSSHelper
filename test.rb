# encoding: UTF-8

load 'validator.rb'
load 'tag_lister.rb'
load 'visualise_changes.rb'
load 'git.rb'
require 'open3'
include Info
include Validator

def main
	visualise_changes({'highway' => 'motorway', 'name' => 'name', 'ref' => '1'}, 'way', false, 4..22, 'master', 'master')
	visualise_changes({'amenity' => 'parking', 'name' => 'name'}, 'node', false, 4..22, 'master', 'master')
	#visualise_changes({'amenity' => 'parking', 'name' => 'name'}, 'closed_way', false, 4..22, 'master', 'master')
	#visualise_changes({'amenity' => 'parking', 'name' => 'name'}, 'way', false, 4..22, 'master', 'master')
	init_commit_hash
	Info.list_render_state
	Validator.run_tests
end

main

