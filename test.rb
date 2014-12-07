# encoding: UTF-8

load 'validator.rb'
load 'tag_lister.rb'
load 'visualise_changes.rb'
load 'git.rb'
require 'open3'

def main
	visualise_changes({'amenity' => 'parking', 'name' => 'name'}, 'node', false, 4..22, 'master', 'master')
	visualise_changes({'amenity' => 'parking', 'name' => 'name'}, 'closed_way', false, 4..22, 'master', 'master')
	visualise_changes({'amenity' => 'parking', 'name' => 'name'}, 'way', false, 4..22, 'master', 'master')
	init_commit_hash
	list_render_state
	run_tests
end

main

