# encoding: UTF-8

load 'validator.rb'
load 'tag_lister.rb'
load 'git.rb'
require 'open3'

def main
	init_commit_hash
	list_render_state
	run_tests
end

main

