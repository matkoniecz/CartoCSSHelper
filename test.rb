# encoding: UTF-8

load 'validator.rb'
load 'tag_lister.rb'

def main
	Dir.chdir(get_style_path) {
		require 'open3'
		Open3.popen3('git log -n 1 --pretty=format:"%H"') {|i, stdout, stderr, t|
			$commit = stdout.read.chomp
			error = stderr.read.chomp
			if error != ''
				raise error
			end
		}
	}
	list_render_state
	run_tests
end

main

