require_relative 'util/systemhelper.rb'

include SystemHelper

module CartoCSSHelper
  class TilemillHandler
    def self.run_tilemill_export_image(lat, lon, zlevel, bbox_size, image_size, export_filename, debug = false)
      if File.exist?(export_filename)
        if debug
          puts 'wanted file exists'
        end
        return
      end
      bbox = get_bbox_string(lat, lon, bbox_size)
      params = "--format=png --width=#{image_size} --height=#{image_size} --static_zoom=#{zlevel} --bbox=\"#{bbox}\""
      project_name = CartoCSSHelper::Configuration.get_tilemill_project_name
      command = "node /usr/share/tilemill/index.js export #{project_name} '#{export_filename}' #{params}"

      begin
        execute_command(command, debug)
      rescue FailedCommandException => e
        unless debug
          puts 'rerunning failed image generation with enabled debug'
          return self.run_tilemill_export_image(lat, lon, zlevel, bbox_size, image_size, export_filename, true)
        end
        raise 'generation of file ' + export_filename + ' failed'
      end
      raise 'silent failure' unless File.exist?(export_filename)
    end

    def get_bbox_string(lat, lon, bbox_size)
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
