# encoding: UTF-8
require 'open3'

module CartoCSSHelper
end
require_relative 'cartocss_helper/tag_lister.rb'
require_relative 'cartocss_helper/visualise_changes_image_generation.rb'
require_relative 'cartocss_helper/downloader.rb'
require_relative 'cartocss_helper/data_file_handling.rb'
require_relative 'cartocss_helper/validator.rb'
require_relative 'cartocss_helper/git.rb'
require_relative 'data/testing_locations'
include CartoCSSHelper::Validator
include CartoCSSHelper::Git

module CartoCSSHelper
  def self.test_tag_on_real_data(tags, new_branch, old_branch, zlevels, types=['node', 'closed_way', 'way'], min = 4, skip = 0)
    types.each {|type|
      test_tag_on_real_data_for_this_type(tags, new_branch, old_branch, zlevels, type, min, skip)
    }
  end

  def self.test_tag_on_real_data_for_this_type(tags, new_branch, old_branch, zlevels, type, min = 4, skip = 0)
    generated = 0

    n = 0
    max_n = get_maxn_for_nth_location
    max_n -= skip
    skip_string = ''
    if skip > 0
      skip_string = " (#{skip} locations skipped)"
    end
    while generated < min
      location = get_nth_location(n + skip)
      generated +=1 if CartoCSSHelper::VisualDiff.visualise_changes_on_real_data(tags, type, location[0], location[1], zlevels, new_branch, old_branch)
      n+=1
      if n > max_n
        return
      end
      puts "#{n}/#{max_n} locations checked #{skip_string}. #{generated}/#{min} testing location found"
    end
  end

  def self.get_maxn_for_nth_location
    return get_list_of_testing_locations.length-1
  end

  def self.get_nth_location(n)
    return get_list_of_testing_locations[n]
  end


  def self.add_common_secondary_tags(tags)
    added_tags = {'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000', 'operator' => 'ÉÉ ÉÉ ÉÉ operator', 'brand' => 'ÉÉ ÉÉ ÉÉ brand'}
    return tags.merge(added_tags)
  end

  def self.test_tag_on_sythetic_data(tags, new_branch, old_branch='master', zlevels=Configuration.get_min_z..Configuration.get_max_z, types=['node', 'closed_way', 'way'], test_on_water=false)
    syn_tags = add_common_secondary_tags(tags)
    types.each {|type|
      CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test(syn_tags, type, test_on_water, zlevels, new_branch, old_branch)
    }
  end

  def self.test(tags, new_branch, old_branch='master', zlevels=Configuration.get_min_z..Configuration.get_max_z, types=['node', 'closed_way', 'way'], test_on_water=false)
    puts "processing #{VisualDiff.dict_to_pretty_tag_list(tags)}"
    test_tag_on_sythetic_data(tags, new_branch, old_branch, zlevels, types, test_on_water)
    test_tag_on_real_data(tags, new_branch, old_branch, zlevels, types)
  end

  def self.probe(tags, new_branch, old_branch='master', zlevels=Configuration.get_min_z..Configuration.get_max_z, types=['node', 'closed_way', 'way'], test_on_water=false)
    syn_tags = add_common_secondary_tags(tags)
    types.each {|type|
      CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test(syn_tags, type, test_on_water, zlevels, new_branch, old_branch)
    }
  end

  def self.visualise_place_by_url(url, zlevels, new_branch, old_branch='master', header=nil, download_bbox_size=0.04, image_size = 350)
    raise "#{url} is not a string, it is #{url.class}" unless url.class == String
    raise "#{zlevels} is not a range, it is #{zlevels.class}" unless zlevels.class == Range
    raise "#{new_branch} is not a string, it is #{new_branch.class}" unless new_branch.class == String
    raise "#{old_branch} is not a string, it is #{old_branch.class}" unless old_branch.class == String
    raise "#{header} is not a string, it is #{header.class}" unless header.class == String
    raise "#{download_bbox_size} is not a number" unless download_bbox_size.kind_of? Numeric
    raise "#{image_size} is not a integer" unless image_size.kind_of? Integer

    latitude = url.scan(/[\/=]((-|)\d+(\.\d+))/)[0][0].to_f
    longitude = url.scan(/[\/=]((-|)\d+(\.\d+))/)[1][0].to_f
    if header == nil
      header = url
    end
    header += ' ' + old_branch + '->' + new_branch + ' ' + zlevels.to_s + ' '+ image_size.to_s + 'px'
    CartoCSSHelper::VisualDiff.visualise_changes_for_location(latitude, longitude, zlevels, header, new_branch, old_branch, download_bbox_size, image_size)
  end

  def self.get_place_of_storage_of_resource_under_url(url)
    return CartoCSSHelper::Configuration.get_path_to_folder_for_overpass_cache + '.manual.cache' + FileHelper::make_string_usable_as_filename(url)
  end

  def self.download_remote_file(url)
    filename = get_place_of_storage_of_resource_under_url(url)
    if !File.exists?(filename)
      begin
        url = url
        timeout = 600
        data = RestClient::Request.execute(:method => :get, :url => url, :timeout => timeout)
      rescue => e
        puts "visualise_place_by_remote_file failed to fetch #{url}"
        raise e
      end
      file = File.new(filename, 'w')
      file.write data
      file.close
    end
  end

  def self.visualise_place_by_remote_file(url, latitude, longitude, zlevels, new_branch, old_branch='master', header=nil, bb=0.04, image_size = 350)
    download_remote_file(url)
    filename = get_place_of_storage_of_resource_under_url(url)
    visualise_place_by_file(filename, latitude, longitude, zlevels, new_branch, old_branch, header, bb, image_size)
  end

  def self.visualise_place_by_file(filename, latitude, longitude, zlevels, new_branch, old_branch='master', header=nil, bb=0.04, image_size = 350)
    raise "#{filename} does not exists" unless File.exists?(filename)
    raise "#{latitude} is not a number" unless latitude.kind_of? Numeric
    raise "#{longitude} is not a number" unless longitude.kind_of? Numeric
    raise "#{zlevels} is not a range" unless zlevels.class == Range
    raise "#{new_branch} is not a string" unless new_branch.class == String
    raise "#{old_branch} is not a string" unless old_branch.class == String
    raise "#{header} is not a string" unless header.class == String
    raise "#{bb} is not a number" unless bb.kind_of? Numeric
    raise "#{image_size} is not a integer" unless image_size.kind_of? Integer

    if header == nil
      header = filename
    end
    header += ' ' + old_branch + '->' + new_branch + '[' + latitude.to_s + ',' + longitude.to_s + ']' + ' ' + image_size.to_s + 'px'
    CartoCSSHelper::VisualDiff.visualise_changes_for_location_from_file(filename, latitude, longitude, zlevels, header, new_branch, old_branch, bb, image_size)
  end
end