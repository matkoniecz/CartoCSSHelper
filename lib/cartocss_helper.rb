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
include CartoCSSHelper::Validator
include CartoCSSHelper::Git

module CartoCSSHelper
  def  self.test_tag_on_real_data(tags, new_branch, old_branch, zlevels, types=['node', 'closed_way', 'way'])
    types.each {|type|
      test_tag_on_real_data_for_this_type(tags, new_branch, old_branch, zlevels, type)
    }
  end

  def self.test_tag_on_real_data_for_this_type(tags, new_branch, old_branch, zlevels, type)
    #special support for following tag values:  :any_value
    krakow_latitude = 50.1
    krakow_longitude = 19.9
    CartoCSSHelper::VisualDiff.visualise_changes_on_real_data(tags, type, krakow_latitude, krakow_longitude, zlevels, old_branch, new_branch)
    japan_latitude = 36.1
    japan_longitude = 140.7
    CartoCSSHelper::VisualDiff.visualise_changes_on_real_data(tags, type, japan_latitude, japan_longitude, zlevels, old_branch, new_branch)
    russia_latitude = 54.8
    russia_longitude = 31.7
    CartoCSSHelper::VisualDiff.visualise_changes_on_real_data(tags, type, russia_latitude, russia_longitude, zlevels, old_branch, new_branch)
    mecca_latitude = 21.3
    mecca_longitude = 39.5
    CartoCSSHelper::VisualDiff.visualise_changes_on_real_data(tags, type, mecca_latitude, mecca_longitude, zlevels, old_branch, new_branch)
    georgia_latitude = 41.4
    georgia_longitude = 44.5
    CartoCSSHelper::VisualDiff.visualise_changes_on_real_data(tags, type, georgia_latitude, georgia_longitude, zlevels, old_branch, new_branch)
    london_latitude = 51.5
    london_longitude = -0.1
    CartoCSSHelper::VisualDiff.visualise_changes_on_real_data(tags, type, london_latitude, london_longitude, zlevels, old_branch, new_branch)
    #TODO: solve problems with response too big to store in memory
    #utrecht_latitude =  52.09
    #utrecht_longitude = 5.11
    #CartoCSSHelper::VisualDiff.visualise_changes_on_real_data(tags, type, utrecht_latitude, utrecht_longitude, zlevels, old_branch, new_branch)
    rural_uk_latitude =  53.2
    rural_uk_longitude = -1.8
    CartoCSSHelper::VisualDiff.visualise_changes_on_real_data(tags, type, rural_uk_latitude, rural_uk_longitude, zlevels, old_branch, new_branch)
  end

  def self.add_common_secondary_tags(tags)
    added_tags = {'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000', 'operator' => 'ÉÉ ÉÉ ÉÉ operator', 'brand' => 'ÉÉ ÉÉ ÉÉ brand'}
    return tags.merge(added_tags)
  end

  def self.test(tags, new_branch, old_brach='master', zlevels=Configuration.get_min_z..Configuration.get_max_z, types=['node', 'closed_way', 'way'], test_on_water=false)
    puts "processing #{VisualDiff.dict_to_pretty_tag_list(tags)}"
    syn_tags = add_common_secondary_tags(tags)
    types.each {|type|
      CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test(syn_tags, type, test_on_water, zlevels, old_brach, new_branch)
    }
    test_tag_on_real_data(tags, new_branch, old_branch, zlevels, types)
  end

  def self.probe(tags, new_branch, old_brach='master', zlevels=Configuration.get_min_z..Configuration.get_max_z, types=['node', 'closed_way', 'way'], test_on_water=false)
    syn_tags = add_common_secondary_tags(tags)
    types.each {|type|
      CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test(syn_tags, type, test_on_water, zlevels, old_brach, new_branch)
    }
  end

  def visualise_place_by_url(url, zlevels, new_branch, old_branch='master', header=nil, bb=0.04, image_size = 450)
    latitude = url.scan(/\/((-|)\d+(\.\d+))/)[0][0].to_f
    longitude = url.scan(/\/((-|)\d+(\.\d+))/)[1][0].to_f
    if header == nil
      header = url
    end
    header += ' ' + old_branch + '->' + new_branch + ' ' + zlevels.to_s + ' '+ image_size.to_s + 'px'
    CartoCSSHelper::VisualDiff.visualise_changes_for_location(latitude, longitude, zlevels, header, old_branch, new_branch, bb, image_size)
  end

  def get_place_of_storage_of_resource_under_url(url)
    return CartoCSSHelper::Configuration.get_path_to_folder_for_overpass_cache + '.manual.cache' + FileHelper::make_string_usable_as_filename(url)
  end

  def download_remote_file(url)
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

  def visualise_place_by_remote_file(url, latitude, longitude, zlevels, new_branch, old_branch='master', header=nil, bb=0.04, image_size = 700)
    download_remote_file(url)
    filename = get_place_of_storage_of_resource_under_url(url)
    visualise_place_by_file(filename, latitude, longitude, zlevels, new_branch, old_branch, header, bb, image_size)
  end

  def visualise_place_by_file(filename, latitude, longitude, zlevels, new_branch, old_branch='master', header=nil, bb=0.04, image_size = 700)
    if header == nil
      header = filename
    end
    header += ' ' + old_branch + '->' + new_branch + '[' + latitude.to_s + ',' + longitude.to_s + ']' + ' ' + image_size.to_s + 'px'
    CartoCSSHelper::VisualDiff.visualise_changes_for_location_from_file(filename, latitude, longitude, zlevels, header, old_branch, new_branch, bb, image_size)
  end
end