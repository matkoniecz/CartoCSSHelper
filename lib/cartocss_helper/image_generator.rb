# encoding: UTF-8
require_relative 'configuration.rb'
require_relative 'heuristic.rb'
require_relative 'data_file_handling.rb'
require_relative 'renderer_handler.rb'
require 'fileutils'
include CartoCSSHelper::Configuration
include CartoCSSHelper::Heuristic

module CartoCSSHelper
  # Defines and generates images for synthethic comparison
  # it is mostly glue between renderer and generator of synthethic data files
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
      @generated_image_location = nil
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

    def get_image_filename(debug = false) # TODO: misleading name - should be location
      lat = 0
      lon = 20
      lon = 0 if @on_water
      return @generated_image_location if File.exist?(@generated_image_location)
      description = "tags: #{@tags.to_s}, zlevel: #{@zlevel}, type: #{@type} #{on_water_string}"
      puts "generating: #{description}" if @show_what_is_generated
      generate_map(lat, lon, debug)
      unless File.exist?(@generated_image_location) && @generated_image_location != nil
        raise "get_image failed - #{description}. File <\n#{@generated_image_location}\n> was expected."
      end
      return @generated_image_location
    end

    protected

    def get_filename
      water_part = ''
      water_part = '_water' if @on_water
      return @tags.to_a.sort.to_s + '_' + @zlevel.to_s + water_part + '_' + @type + '.png'
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
      @generated_image_location = RendererHandler.request_image_from_renderer(lat, lon, @zlevel, [bbox_size, bbox_size], 200, export_filename, debug)
    end
  end
end
