require_relative 'visualise_changes_diff_from_images'
require_relative 'git'
require_relative 'downloader'
require_relative 'util/filehelper'

module CartoCSSHelper
  class VisualDiff
    @@job_pooling = false
    @@jobs = []

    def self.enable_job_pooling
      #it results in avoiding loading the same database mutiple times
      #useful if the same database will be used multiple times (for example the same place in multiple comparisons)
      #use run_jobs function to run jobs
      @@job_pooling = true
    end

    def self.disable_job_pooling
      @@job_pooling = false
    end

    class MapGenerationJob
      attr_reader :filename, :active
      def initialize(filename, latitude, longitude, zlevels, header, new_branch, old_branch, download_bbox_size, image_size)
        @filename = filename
        @latitude = latitude
        @longitude = longitude
        @zlevels = zlevels
        @header = header
        @old_branch = old_branch
        @new_branch = new_branch
        @download_bbox_size = download_bbox_size
        @image_size = image_size
        @active = true
      end
      def run_job
        if !@active
          return
        end
        print
        source = CartoCSSHelper::VisualDiff::FileDataSource.new(@latitude, @longitude, @download_bbox_size, @filename)
        CartoCSSHelper::VisualDiff.visualise_changes_for_given_source(@latitude, @longitude, @zlevels, @header, @new_branch, @old_branch, @image_size, source)
        @active = false
      end
      def print
        puts "#{@filename.gsub(Configuration.get_path_to_folder_for_cache, '#')} [#{@latitude};#{@longitude}], z: #{@zlevels}, text: #{@header}, '#{@old_branch}'->'#{@new_branch}', bbox:#{@download_bbox_size}, #{@image_size}px"
      end
    end

    def self.add_job(filename, latitude, longitude, zlevels, header, new_branch, old_branch, download_bbox_size, image_size)
      print 'pool <- '
      new_job = MapGenerationJob.new(filename, latitude, longitude, zlevels, header, new_branch, old_branch, download_bbox_size, image_size)
      new_job.print

      raise "#{filename} does not exists" unless File.exists?(filename)
      raise "#{latitude} is not a number" unless latitude.kind_of? Numeric
      raise "#{longitude} is not a number" unless longitude.kind_of? Numeric
      raise "#{zlevels} is not a range" unless zlevels.class == Range
      raise "#{header} is not a string" unless header.class == String
      raise "#{new_branch} is not a string" unless new_branch.class == String
      raise "#{old_branch} is not a string" unless old_branch.class == String
      raise "#{download_bbox_size} is not a number" unless download_bbox_size.kind_of? Numeric
      raise "#{image_size} is not a integer" unless image_size.kind_of? Integer

      @@jobs.push(new_job)
    end

    def self.run_jobs
      for i in 0..@@jobs.length-1
        if @@jobs[i].active
          @@jobs[i].run_job
          for x in 0..@@jobs.length-1
            if @@jobs[i].filename == @@jobs[x].filename
              @@jobs[x].run_job
            end
          end
        end
      end
      @@jobs = []
    end

    def self.visualise_changes_synthethic_test(tags, type, on_water, zlevel_range, new_branch, old_branch)
      tags = VisualDiff.remove_magic_from_tags(tags)
      on_water_string = ''
      if on_water
        on_water_string = ' on water'
      end
      header = "#{ VisualDiff.dict_to_pretty_tag_list(tags) } #{ type }#{ on_water_string }"
      puts "visualise_changes_synthethic_test <#{header}> #{old_branch} -> #{new_branch}"
      Git.checkout(old_branch)
      old = VisualDiff.collect_images_for_synthethic_test(tags, type, on_water, zlevel_range)
      Git.checkout(new_branch)
      new = VisualDiff.collect_images_for_synthethic_test(tags, type, on_water, zlevel_range)
      VisualDiff.pack_image_sets old, new, header, new_branch, old_branch, 200
    end

    def self.remove_magic_from_tags(tags)
      magicless_tags = Hash.new
      tags.each {|key, value|
        if value == :any
          value = 'any tag value'
        end
        magicless_tags[key]=value
      }
      return magicless_tags
    end

    def self.collect_images_for_synthethic_test(tags, type, on_water, zlevel_range)
      collection = []
      zlevel_range.each { |zlevel|
        scene = Scene.new(tags, zlevel, on_water, type)
        collection.push(ImageForComparison.new(scene.get_image_filename, "z#{zlevel}"))
      }
      return collection
    end

    class FileDataSource
      attr_reader :download_bbox_size, :data_filename
      def initialize(latitude, longitude, download_bbox_size, filename)
        @download_bbox_size = download_bbox_size
        @latitude = latitude
        @longitude = longitude
        @data_filename = filename
        @loaded = false
      end

      def load
        if !@loaded
          DataFileLoader.load_data_into_database(@data_filename)
          puts "\tgenerating images"
          @loaded = true
        end
      end

      def get_timestamp
        return Downloader.get_timestamp_of_file(@data_filename)
      end
    end

    def self.visualise_changes_on_real_data(tags, type, wanted_latitude, wanted_longitude, zlevels, new_branch, old_branch='master')
      #special support for following tag values:  :any_value
      header = "#{ VisualDiff.dict_to_pretty_tag_list(tags) } #{type} #{ wanted_latitude } #{ wanted_longitude } #{zlevels}"
      puts "visualise_changes_on_real_data <#{header}> #{old_branch} -> #{new_branch}"
      begin
        latitude, longitude = Downloader.locate_element_with_given_tags_and_type tags, type, wanted_latitude, wanted_longitude
      rescue Downloader::OverpassRefusedResponse
        puts 'No nearby instances of tags and tag is not extremely rare - no generation of nearby location and wordwide search was impossible. No diff image will be generated for this location.'
        return false
      end
      header = "#{ VisualDiff.dict_to_pretty_tag_list(tags) } #{type} #{ wanted_latitude } #{ wanted_longitude } #{zlevels}"
      download_bbox_size = 0.4
      visualise_changes_for_location(latitude, longitude, zlevels, header, new_branch, old_branch, download_bbox_size)
      return true
    end

    def self.visualise_changes_for_location(latitude, longitude, zlevels, header, new_branch, old_branch, download_bbox_size, image_size=400)
      filename = Downloader.get_file_with_downloaded_osm_data_for_location(latitude, longitude, download_bbox_size)
      visualise_changes_for_location_from_file(filename, latitude, longitude, zlevels, header, new_branch, old_branch, download_bbox_size, image_size)
    end

    def self.visualise_changes_for_location_from_file(filename, latitude, longitude, zlevels, header, new_branch, old_branch, download_bbox_size, image_size=400)
      prefix = ''
      if @@job_pooling
        prefix = 'pool <- '
      end
      add_job(filename, latitude, longitude, zlevels, header, new_branch, old_branch, download_bbox_size, image_size)
      if !@@job_pooling
        run_jobs
      end
    end

    def self.visualise_changes_for_given_source(latitude, longitude, zlevels, header, new_branch, old_branch, image_size, source)
      Git.checkout old_branch
      old = VisualDiff.collect_images_for_real_data_test(latitude, longitude, zlevels, source, image_size)
      Git.checkout new_branch
      new = VisualDiff.collect_images_for_real_data_test(latitude, longitude, zlevels, source, image_size)
      VisualDiff.pack_image_sets old, new, header, new_branch, old_branch, image_size
    end

    def self.scale(zlevel, reference_value, reference_zlevel)
      diff = zlevel - reference_zlevel
      rescaler = 2.0**diff
      return reference_value*rescaler
    end

    def self.collect_images_for_real_data_test(latitude, longitude, zlevels, source, wanted_image_size=400)
      collection = []
      zlevels.each { |zlevel|
        image_size_for_16_zoom_level = 1000
        image_size = (VisualDiff.scale zlevel, image_size_for_16_zoom_level, 16)
        mutiplier = 1000
        image_size = (image_size*mutiplier).to_int
        render_bbox_size = 0.015
        ratio = 1.0*image_size/(wanted_image_size*mutiplier)
        image_size /= ratio
        render_bbox_size /= ratio
        image_size /= mutiplier
        image_size = image_size.to_i
        if image_size!=wanted_image_size
          puts VisualDiff.scale zlevel, image_size_for_16_zoom_level, 16
          puts zlevel
          puts image_size
          puts wanted_image_size
          puts ratio
          raise "#{image_size} mismatches #{wanted_image_size}"
        end
        cache_folder = CartoCSSHelper::Configuration.get_path_to_folder_for_branch_specific_cache
        filename = "#{cache_folder+"#{latitude} #{longitude} #{zlevel}zlevel #{image_size}px #{source.get_timestamp} #{source.download_bbox_size}.png"}"
        if !File.exists?(filename)
          source.load
          TilemillHandler.run_tilemill_export_image(latitude, longitude, zlevel, render_bbox_size, image_size, filename)
        end
        collection.push(ImageForComparison.new(filename, "z#{zlevel}"))
      }
      return collection
    end

    def self.pack_image_sets(old, new, header, new_branch, old_branch, image_size)
      old_branch = FileHelper::make_string_usable_as_filename(old_branch)
      new_branch = FileHelper::make_string_usable_as_filename(new_branch)
      header_for_filename = FileHelper::make_string_usable_as_filename(header)
      filename_sufix = "#{ old_branch } -> #{ new_branch }"
      filename = CartoCSSHelper::Configuration.get_path_to_folder_for_output + "#{header_for_filename} #{filename_sufix} #{image_size}px.png"
      diff = FullSetOfComparedImages.new(old, new, header, filename, image_size)
      diff.save
    end

    def self.dict_to_pretty_tag_list(dict)
      result = ''
      dict.to_a.each { |tag|
        if result != ''
          result << '; '
        end
        value = "'#{tag[1]}'"
        if tag[1] == :any_value
          value = '{any value}'
        end
        result << "#{tag[0]}=#{value}"
      }
      return result
    end
  end
end
