require_relative 'util/systemhelper.rb'

include SystemHelper

module CartoCSSHelper
  class TilemillFailedToGenerateFile < StandardError
  end

  class TilemillHandler
    def self.cache_exists(export_filename, debug)
      if File.exist?(export_filename)
        puts 'wanted file exists' if debug
        return true
      end
      return false
    end

    def self.command(lat, lon, zlevel, bbox_size, image_size, export_filename)
      bbox = get_bbox_string(lat, lon, bbox_size)
      params = "--format=png --width=#{image_size} --height=#{image_size} --static_zoom=#{zlevel} --bbox=\"#{bbox}\""
      project_name = CartoCSSHelper::Configuration.get_tilemill_project_name
      return "node /usr/share/tilemill/index.js export #{project_name} '#{export_filename}' #{params}"
    end

    def self.run_tilemill_export_image(lat, lon, zlevel, bbox_size, image_size, export_filename, debug = false)
      start = Time.now

      return if cache_exists(export_filename, debug)
      command_to_execute = command(lat, lon, zlevel, bbox_size, image_size, export_filename)
      output = nil
      begin
        output = execute_command(command_to_execute, debug, ignore_stderr_presence: true)
      rescue FailedCommandException => e
        puts e
        raise TilemillFailedToGenerateFile, "generation of file #{export_filename} failed due to #{e}"
      end

      puts "generated in #{(Time.now - start).to_i} s"

      return if cache_exists(export_filename, false)
      raise TilemillFailedToGenerateFile, "generation of file #{export_filename} silently failed with command <#{command_to_execute}> and output <#{output}>"
    end

    def self.get_bbox_string(lat, lon, bbox_size)
      latitude_bb_size = bbox_size[0]
      longitude_bb_size = bbox_size[1]
      #--bbox=[xmin,ymin,xmax,ymax]
      xmin = lon - longitude_bb_size / 2
      ymin = lat - latitude_bb_size / 2
      xmax = lon + longitude_bb_size / 2
      ymax = lat + latitude_bb_size / 2
      return "#{xmin},#{ymin},#{xmax},#{ymax}"
    end
  end
end
