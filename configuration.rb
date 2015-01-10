# encoding: UTF-8
require 'fileutils'
load 'style_specific/default_osm_style.rb' #TODO - stop hardcoding this

module Configuration
	def get_max_z
		return 22
	end

	def get_min_z
		return 4
	end

	def get_style_path
		return File.join(ENV['HOME'], 'Documents', 'OSM', 'tilemill', 'osm-carto', '') #TODO - stop hardcoding this
	end

	def get_path_to_folder_for_output
		#TODO - stop hardcoding this
		location = File.join(ENV['HOME'], 'Documents', 'OSM', 'tilemill', 'CartoCSSHelper', 'output', '')
		FileUtils::mkdir_p location
		return location
	end

	def get_path_to_folder_for_general_temporary_files
		#TODO - stop hardcoding this
		location = File.join(ENV['HOME'], 'Documents', 'OSM', 'tilemill', 'CartoCSSHelper', 'cache', '')
		FileUtils::mkdir_p location
		return location
	end

	def get_path_to_folder_for_branch_specific_temporary_files
		#TODO - stop hardcoding this
		location = File.join(get_path_to_folder_for_general_temporary_files, $commit, '')
		FileUtils::mkdir_p location
		return location
	end

	def get_path_to_folder_for_overpass_cache
		#TODO - stop hardcoding this
		location = File.join(get_path_to_folder_for_general_temporary_files, 'overpass', '')
		FileUtils::mkdir_p location
		return location
	end

	def get_data_filename
		return get_path_to_folder_for_branch_specific_temporary_files+'data.osm'
	end
end