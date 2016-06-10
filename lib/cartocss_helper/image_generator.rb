# encoding: UTF-8
require_relative 'configuration.rb'
require_relative 'heuristic.rb'
require_relative 'data_file_handling.rb'
require_relative 'tilemill_handler.rb'
require 'fileutils'
include CartoCSSHelper::Configuration
include CartoCSSHelper::Heuristic

module CartoCSSHelper
  class Scene
    attr_reader :tags, :zlevel, :on_water, :type
    def initialize(tags, zlevel, on_water, type, show_what_is_generated = false)
      @show_what_is_generated = show_what_is_generated
      raise 'tags not in hash' unless tags.respond_to?(:has_key?)
      @tags = tags
      @zlevel = zlevel
      @on_water = on_water
      @type = type
      if type == 'area'
        @tags['area'] = 'yes'
        @type = 'closed_way'
      end
    end

    def is_output_different(another_scene)
      raise 'on_water mismatch' if @on_water != another_scene.on_water
      return !is_output_identical(another_scene)
    end

    def is_output_identical(another_scene)
      raise 'on_water mismatch' if @on_water != another_scene.on_water
      # Returns true if the contents of a file A and a file B are identical.
      return FileUtils.compare_file(self.get_image_filename, another_scene.get_image_filename)
    end

    def flush_cache
      File.delete(self.get_filename)
    end

    def on_water_string
      on_water_string = ''
      on_water_string = 'on_water' if @on_water
      return on_water_string
    end

    def get_image_filename(debug = false)
      lat = 0
      lon = 20
      lon = 0 if @on_water
      export_filename = self.get_filename
      return export_filename if File.exist?(export_filename)
      description = "tags: #{@tags.to_s}, zlevel: #{@zlevel}, type: #{@type} #{on_water_string}"
      puts "generating: #{description}" if @show_what_is_generated
      generate_map(lat, lon, debug)
      unless File.exist?(export_filename)
        description = "get_image failed - #{description}. File <\n#{export_filename}\n> was expected."
        if debug
          raise description
        else
          puts description
          return get_image_filename(true)
        end
      end
      return export_filename
    end

    protected

    def get_filename
      water_part = ''
      water_part = '_water' if @on_water
      return Configuration.get_path_to_folder_for_branch_specific_cache + @tags.to_a.sort.to_s + '_' + @zlevel.to_s + water_part + '_' + @type + '.png'
    end

    def generate_map(lat, lon, debug)
      data_file_maker = DataFileGenerator.new(tags, @type, lat, lon, get_bbox_size)
      data_file_maker.generate
      DataFileLoader.load_data_into_database(Configuration.get_data_filename, debug)
      generate_image lat, lon, debug
    end

    def get_bbox_size
      return 0.2
    end

    def generate_image(lat, lon, debug)
      export_filename = self.get_filename
      bbox_size = self.get_bbox_size
      TilemillHandler.run_tilemill_export_image(lat, lon, @zlevel, [bbox_size, bbox_size], 200, export_filename, debug)
    end
  end
end
