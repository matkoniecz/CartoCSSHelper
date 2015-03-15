# encoding: UTF-8
require 'fileutils'
require 'find'

load 'style_specific/default_osm_style.rb'

module CartoCSSHelper::Configuration
  def set_style_specific_data(data)
    @style_specific_data = data
  end

  def get_style_specific_data
    if @style_specific_data == nil
      raise 'Set your configuration data using CartoCSSHelper::Configuration.set_style_specific_data(data)'
    end
    return @style_specific_data
  end

	def get_max_z
    return get_style_specific_data.max_z
	end

	def get_min_z
    if @style_specific_data == nil
      raise 'Set your configuration data using CartoCSSHelper::Configuration.set_style_specific_data(data)'
    end
    return get_style_specific_data.min_z
	end

  def set_path_to_tilemill_project_folder(path)
    @style_path = path
  end

	def get_path_to_tilemill_project_folder
    if @style_path == nil
      raise 'Set your configuration data using CartoCSSHelper::Configuration.set_style_path(path)'
    end
		return @style_path
	end

  def get_tilemill_project_name
    return get_path_to_tilemill_project_folder.split(File::SEPARATOR)[-1]
  end

  def get_style_file_location
    if @style_file == nil
      @style_file = find_style_file_location
    end
    return @style_file
  end

  def find_style_file_location
    Find.find(get_path_to_tilemill_project_folder) do |path|
      if path =~ /.*\.style$/
        return path
      end
    end
  end

	def get_path_to_folder_for_output
		location = File.join(File.dirname(__FILE__), 'output', '')
		FileUtils::mkdir_p location
		return location
	end

	def get_path_to_folder_for_cache
    location = File.join(File.dirname(__FILE__), 'cache', '')
		FileUtils::mkdir_p location
		return location
	end

	def get_path_to_folder_for_branch_specific_cache
		location = File.join(get_path_to_folder_for_cache, CartoCSSHelper::Git.get_commit_hash, '')
		FileUtils::mkdir_p location
		return location
	end

	def get_path_to_folder_for_overpass_cache
		location = File.join(get_path_to_folder_for_cache, 'overpass', '')
		FileUtils::mkdir_p location
		return location
	end

	def get_data_filename
		return get_path_to_folder_for_branch_specific_cache+'data.osm'
	end
end