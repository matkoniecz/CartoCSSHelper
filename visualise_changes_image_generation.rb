require_relative 'visualise_changes_diff_from_images'
require_relative 'git'
require_relative 'downloader'

class VisualDiff
  def self.visualise_changes_synthethic_test(tags, type, on_water, zlevel_range, old_branch, new_branch)
    tags = VisualDiff.remove_magic_from_tags(tags)
    on_water_string = ''
    if on_water
      on_water_string = ' on water'
    end
    header = "#{ VisualDiff.dict_to_pretty_tag_list(tags) } #{ type }#{ on_water_string }"
    puts "visualise_changes_synthethic_test <#{header}> #{old_branch} -> #{new_branch}"
    Git.switch_to_branch(old_branch)
    old = VisualDiff.collect_images_for_synthethic_test(tags, type, on_water, zlevel_range)
    Git.switch_to_branch(new_branch)
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
    def initialize(latitude, longitude, wanted_download_bbox_size)
      wanted_download_bbox_size = [wanted_download_bbox_size, 0.001].max
      wanted_download_bbox_size = [wanted_download_bbox_size, 0.500].min #0.9 fails in Tokio
      @download_bbox_size = wanted_download_bbox_size
      @latitude = latitude
      @longitude = longitude
      puts "\tdownloading location (OverpassAPI)"
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
      f = File.new(@data_filename)
      return f.mtime.to_i
    end
  end

  def self.visualise_changes_on_real_data(tags, wanted_latitude, wanted_longitude, zlevels, old_branch, new_branch)
    header = "#{ VisualDiff.dict_to_pretty_tag_list(tags) } #{ wanted_latitude } #{ wanted_longitude } #{zlevels}"
    puts "visualise_changes_on_real_data <#{header}> #{old_branch} -> #{new_branch}"
    puts "\tlocating nearby element (OverpassAPI)"
    latitude, longitude = Downloader.locate_element_with_given_tags tags, wanted_latitude, wanted_longitude
    download_bbox_size = VisualDiff.scale_inverse zlevels.min, 0.03, 14
    source = RealDataSource.new(latitude, longitude, download_bbox_size)
    Git.switch_to_branch old_branch
    old = VisualDiff.collect_images_for_real_data_test(tags, latitude, longitude, zlevels, source)
    Git.switch_to_branch new_branch
    new = VisualDiff.collect_images_for_real_data_test(tags, latitude, longitude, zlevels, source)
    header = "#{ VisualDiff.dict_to_pretty_tag_list(tags) } #{latitude} #{longitude}"
    VisualDiff.pack_image_sets old, new, header, old_branch, new_branch, 400
  end

  def self.scale_inverse(zlevel, reference_value, reference_zlevel)
    return VisualDiff.scale reference_zlevel, reference_value, zlevel
  end

  def self.scale(zlevel, reference_value, reference_zlevel)
    diff = zlevel - reference_zlevel
    rescaler = 2.0**diff
    return reference_value*rescaler
  end

  def self.collect_images_for_real_data_test(tags, latitude, longitude, zlevels, source)
    collection = []
    zlevels.each { |zlevel|
      image_size_for_16_zoom_level = 1000
      image_size = (VisualDiff.scale zlevel, image_size_for_16_zoom_level, 16)
      mutiplier = 1000
      image_size = (image_size*mutiplier).to_int
      render_bbox_size = 0.015
      wanted_image_size = 400
      ratio = 1.0*image_size/(wanted_image_size*mutiplier)
      image_size /= ratio
      render_bbox_size /= ratio
      image_size /= mutiplier
      if image_size!=wanted_image_size
        puts VisualDiff.scale zlevel, image_size_for_16_zoom_level, 16
        puts zlevel
        puts image_size
        puts wanted_image_size
        puts ratio
        raise "#{image_size} mismatches #{wanted_image_size}"
      end
      filename = "#{get_path_to_folder_for_branch_specific_temporary_files+"#{tags.to_a.to_s} #{latitude} #{longitude} #{zlevel}zlevel #{image_size}px #{source.get_timestamp}.png"}"
      if !File.exists?(filename)
        source.load
        Scene.run_tilemill_export_image(latitude, longitude, zlevel, render_bbox_size, image_size, filename)
      end
      collection.push(ImageForComparison.new(filename, "z#{zlevel}"))
    }
    return collection
  end

  def self.pack_image_sets(old, new, header, old_branch, new_branch, image_size)
    old_branch = old_branch.gsub(/[\x00\/\\:\*\?\"<>\|]/, '_')
    new_branch = new_branch.gsub(/[\x00\/\\:\*\?\"<>\|]/, '_')
    filename_sufix = "#{ old_branch } -> #{ new_branch }"
    filename = get_path_to_folder_for_output + "#{header} #{filename_sufix}.png"
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


