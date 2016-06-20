# encoding: UTF-8
require 'fileutils'
require 'find'

require_relative 'style_specific/default_osm_style.rb'

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
    @style_file = find_style_file_location if @style_file == nil
    return @style_file
  end

  def find_style_file_location
    Find.find(get_path_to_tilemill_project_folder) do |path|
      return path if path =~ /.*\.style$/
    end
  end

  def set_path_to_folder_for_output(path)
    @path_to_folder_for_output = path
  end

  def get_path_to_folder_for_output
    if @path_to_folder_for_output == nil
      raise 'Set your configuration data using CartoCSSHelper::Configuration.set_path_to_folder_for_output(path)'
    end
    FileUtils::mkdir_p @path_to_folder_for_output
    return @path_to_folder_for_output
  end

  def set_path_to_folder_for_cache(path)
    @path_to_folder_for_cache = path
  end

  def get_path_to_folder_for_cache
    if @path_to_folder_for_cache == nil
      raise 'Set your configuration data using CartoCSSHelper::Configuration.set_path_to_folder_for_cache(path)'
    end
    FileUtils::mkdir_p @path_to_folder_for_cache
    return @path_to_folder_for_cache
  end

  def get_path_to_folder_for_branch_specific_cache
    location = File.join(get_path_to_folder_for_cache, 'generated_images', CartoCSSHelper::Git.get_commit_hash, '')
    FileUtils::mkdir_p location
    return location
  end

  def get_path_to_folder_for_overpass_cache
    location = File.join(get_path_to_folder_for_cache, 'overpass', '')
    FileUtils::mkdir_p location
    return location
  end

  def get_path_to_folder_for_notes_api_cache
    location = File.join(get_path_to_folder_for_cache, 'notes-api', '')
    FileUtils::mkdir_p location
    return location
  end

  def get_data_filename
    return get_path_to_folder_for_branch_specific_cache + 'data.osm'
  end

  @overpass_instance_url = 'http://overpass-api.de/api'
  def set_overpass_instance_url(path)
    @overpass_instance_url = path
  end

  def set_known_alternative_overpass_url
    set_overpass_instance_url('http://overpass.osm.rambler.ru/cgi')
  end

  def get_overpass_instance_url
    return @overpass_instance_url
  end
end
