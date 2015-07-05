require_relative 'visualise_changes_diff_from_images'
require_relative 'git'
require_relative 'downloader'

module CartoCSSHelper
  class VisualDiff
    def self.visualise_changes_synthethic_test(tags, type, on_water, zlevel_range, old_branch, new_branch)
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
      VisualDiff.pack_image_sets old, new, header, old_branch, new_branch, 200
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

    class RealDataSource
      attr_reader :download_bbox_size
      def initialize(latitude, longitude, download_bbox_size)
        @download_bbox_size = download_bbox_size
        @latitude = latitude
        @longitude = longitude
        @data_filename = Downloader.download_osm_data_for_location(@latitude, @longitude, @download_bbox_size)
        @loaded = false
      end

      def load
        if !@loaded
          puts "\tloading data into database"
          DataFileLoader.load_data_into_database(@data_filename)
          puts "\tgenerating images"
          @loaded = true
        end
      end

      def get_timestamp
        return Downloader.get_timestamp_of_downloaded_osm_data_for_location(@latitude, @longitude, @download_bbox_size)
      end

      def dispose
        File.delete(@data_filename)
      end
    end

    class FileDataSource
      attr_reader :download_bbox_size
      def initialize(latitude, longitude, download_bbox_size, filename)
        @download_bbox_size = download_bbox_size
        @latitude = latitude
        @longitude = longitude
        @data_filename = filename
        @loaded = false
      end

      def load
        if !@loaded
          puts "\tloading data into database"
          DataFileLoader.load_data_into_database(@data_filename)
          puts "\tgenerating images"
          @loaded = true
        end
      end

      def get_timestamp
        return Downloader.get_timestamp_of_file(@data_filename)
      end

      def dispose
        #do nothing, file generated outside
      end
    end

    def self.visualise_changes_on_real_data(tags, type, wanted_latitude, wanted_longitude, zlevels, old_branch, new_branch)
      #special support for following tag values:  :any_value
      header = "#{ VisualDiff.dict_to_pretty_tag_list(tags) } #{type} #{ wanted_latitude } #{ wanted_longitude } #{zlevels}"
      puts "visualise_changes_on_real_data <#{header}> #{old_branch} -> #{new_branch}"
      begin
        latitude, longitude = Downloader.locate_element_with_given_tags_and_type tags, type, wanted_latitude, wanted_longitude
      rescue Downloader::OverpassRefusedResponse
        puts 'No nearby instances of tags and tag is not extremely rare - no generation of nearby location and wordwide search was impossible. No diff image will be generated for this location.'
        return
      end
      header = "#{ VisualDiff.dict_to_pretty_tag_list(tags) } #{type} #{ wanted_latitude } #{ wanted_longitude } #{zlevels}"
      download_bbox_size = 0.4
      visualise_changes_for_location(latitude, longitude, zlevels, header, old_branch, new_branch, download_bbox_size)
    end

    def self.visualise_changes_for_location(latitude, longitude, zlevels, header, old_branch, new_branch, download_bbox_size, image_size=400)
      source = RealDataSource.new(latitude, longitude, download_bbox_size)
      visualise_changes_for_given_source(latitude, longitude, zlevels, header, old_branch, new_branch, image_size, source)
    end

    def self.visualise_changes_for_location_from_file(filename, latitude, longitude, zlevels, header, old_branch, new_branch, download_bbox_size, image_size=400)
      source = FileDataSource.new(latitude, longitude, download_bbox_size, filename)
      visualise_changes_for_given_source(latitude, longitude, zlevels, header, old_branch, new_branch, image_size, source)
    end

    def self.visualise_changes_for_given_source(latitude, longitude, zlevels, header, old_branch, new_branch, image_size, source)
      Git.checkout old_branch
      old = VisualDiff.collect_images_for_real_data_test(latitude, longitude, zlevels, source, image_size)
      Git.checkout new_branch
      new = VisualDiff.collect_images_for_real_data_test(latitude, longitude, zlevels, source, image_size)
      VisualDiff.pack_image_sets old, new, header, old_branch, new_branch, image_size
      source.dispose
    end

    def self.scale_inverse(zlevel, reference_value, reference_zlevel)
      return VisualDiff.scale reference_zlevel, reference_value, zlevel
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
          Scene.run_tilemill_export_image(latitude, longitude, zlevel, render_bbox_size, image_size, filename)
        end
        collection.push(ImageForComparison.new(filename, "z#{zlevel}"))
      }
      return collection
    end

    def self.make_string_usable_as_filename(string)
      return string.gsub(/[\x00\/\\:\*\?\"<>\|]/, '_')
    end

    def self.pack_image_sets(old, new, header, old_branch, new_branch, image_size)
      old_branch = make_string_usable_as_filename(old_branch)
      new_branch = make_string_usable_as_filename(new_branch)
      header_for_filename = make_string_usable_as_filename(header)
      filename_sufix = "#{ old_branch } -> #{ new_branch }"
      filename = CartoCSSHelper::Configuration.get_path_to_folder_for_output + "#{header_for_filename} #{filename_sufix}.png"
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
