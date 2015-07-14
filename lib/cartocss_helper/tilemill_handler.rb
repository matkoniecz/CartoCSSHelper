module CartoCSSHelper
  class TilemillHandler
    def self.run_tilemill_export_image(lat, lon, zlevel, bbox_size, image_size, export_filename, debug=false)
      if File.exists?(export_filename)
        if debug
          puts 'wanted file exists'
        end
        return
      end
      silence = '> /dev/null 2>&1'
      if debug
        silence = ''
      end
      #--bbox=[xmin,ymin,xmax,ymax]
      xmin = lon-bbox_size/2
      ymin = lat-bbox_size/2
      xmax = lon+bbox_size/2
      ymax = lat+bbox_size/2
      bbox = "#{xmin},#{ymin},#{xmax},#{ymax}"
      params = "--format=png --width=#{image_size} --height=#{image_size} --static_zoom=#{zlevel} --bbox=\"#{bbox}\""
      project_name = CartoCSSHelper::Configuration.get_tilemill_project_name
      command = "node /usr/share/tilemill/index.js export #{project_name} '#{export_filename}' #{params} #{silence}"
      if debug
        puts command
      end
      system command
      unless File.exists?(export_filename)
        if !debug
          puts 'rerunning failed image generation with enabled debug'
          return self.run_tilemill_export_image(lat, lon, zlevel, bbox_size, image_size, export_filename, true)
        end
        raise 'generation of file ' + export_filename + ' failed'
      end
    end
  end
end