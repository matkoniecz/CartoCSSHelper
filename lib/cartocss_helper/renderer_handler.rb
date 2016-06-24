require_relative 'util/systemhelper.rb'

include SystemHelper

module CartoCSSHelper
  class RendererFailedToGenerateFile < StandardError
  end

  class RendererHandler
    def self.cache_exists(export_filename, debug)
      if File.exist?(export_filename)
        puts 'wanted file exists' if debug
        return true
      end
      return false
    end

    def self.tilemill_command(lat, lon, zlevel, bbox_size, image_size, export_filename)
      raise 'mapnik reference overrride impossible for TileMill!' if CartoCSSHelper::Configuration.mapnik_reference_version_override
      bbox = get_bbox_string(lat, lon, bbox_size)
      params = "--format=png --width=#{image_size} --height=#{image_size} --static_zoom=#{zlevel} --bbox=\"#{bbox}\""
      project_name = CartoCSSHelper::Configuration.get_cartocss_project_name
      return "node /usr/share/tilemill/index.js export #{project_name} '#{export_filename}' #{params}"
    end

    def self.kosmtik_command(lat, lon, zlevel, bbox_size, image_size, export_filename)
      mapnik_override = CartoCSSHelper::Configuration.mapnik_reference_version_override
      additional_params = ""
      additional_params += " --mapnik-version=#{mapnik_override}" if mapnik_override
      return base_kosmtik_command(lat, lon, zlevel, bbox_size, image_size, export_filename, additional_params: additional_params)
    end

    def self.magnacarto_command(lat, lon, zlevel, bbox_size, image_size, export_filename)
      mapnik_override = CartoCSSHelper::Configuration.mapnik_reference_version_override
      additional_params = " --renderer=magnacarto"
      additional_params += " --mapnik-version=#{mapnik_override}" if mapnik_override
      return base_kosmtik_command(lat, lon, zlevel, bbox_size, image_size, export_filename, additional_params: additional_params)
    end

    def self.base_kosmtik_command(lat, lon, zlevel, bbox_size, image_size, export_filename, additional_params: '')
      bbox = get_bbox_string(lat, lon, bbox_size)
      params = "--format=png --width=#{image_size} --height=#{image_size} --bounds=\"#{bbox}\""
      project_name = CartoCSSHelper::Configuration.get_cartocss_project_name
      yaml = CartoCSSHelper::Configuration.project_file_location
      kosmtik = "#{CartoCSSHelper::Configuration.path_to_kosmtik}index.js"
      return "node #{kosmtik} export #{yaml} --output '#{export_filename}' #{additional_params} #{params}"
    end

    def self.find_command(lat, lon, zlevel, bbox_size, image_size, export_filename)
      if CartoCSSHelper::Configuration.renderer == :tilemill
        return tilemill_command(lat, lon, zlevel, bbox_size, image_size, export_filename)
      elsif CartoCSSHelper::Configuration.renderer == :kosmtik
        return kosmtik_command(lat, lon, zlevel, bbox_size, image_size, export_filename)
      elsif CartoCSSHelper::Configuration.renderer == :magnacarto
        return magnacarto_command(lat, lon, zlevel, bbox_size, image_size, export_filename)
      end
    end

    def self.renderer_marking
      renderer = "#{CartoCSSHelper::Configuration.renderer}_"
      mapnik_reference = 'mapnik_reference=default_'
      if CartoCSSHelper::Configuration.mapnik_reference_version_override
        mapnik_reference = "mapnik_reference=#{CartoCSSHelper::Configuration.mapnik_reference_version_override}_"
      end
      return "#{renderer}#{mapnik_reference}"
    end

    def self.get_cache_file_location(export_filename)
      cache_folder = CartoCSSHelper::Configuration.get_path_to_folder_for_branch_specific_cache
      return "#{cache_folder}#{renderer_marking}#{export_filename}"
    end

    def self.image_available_from_cache(lat, lon, zlevel, bbox_size, image_size, export_filename, debug = false)
      return File.exist?(get_cache_file_location(export_filename))
    end

    def self.request_image_from_renderer(lat, lon, zlevel, bbox_size, image_size, export_filename, debug = false)
      raise "filename, not path <#{export_filename}> was provided" if export_filename.include?("/")
      export_location = get_cache_file_location(export_filename)
      return export_location if cache_exists(export_location, debug)

      start = Time.now

      command_to_execute = find_command(lat, lon, zlevel, bbox_size, image_size, export_location)
      puts command_to_execute

      execute_rendering_command(command_to_execute, export_location, debug)

      puts "generated in #{(Time.now - start).to_i}s (#{Git.get_commit_hash})"
      return export_location
    end

    def self.execute_rendering_command(command, export_location, debug)
      output = nil
      begin
        output = execute_command(command, debug, ignore_stderr_presence: true)
      rescue FailedCommandException => e
        puts e
        raise RendererFailedToGenerateFile, "generation of file #{export_location} failed due to #{e}"
      end

      return export_location if cache_exists(export_location, false)
      raise RendererFailedToGenerateFile, "generation of file #{export_location} silently failed with command <#{command}> and output <#{output}>"
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
