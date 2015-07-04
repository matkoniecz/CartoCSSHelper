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
  def  self.test_tag_on_real_data(tags, zlevels, old_branch, new_branch, types=['node', 'closed_way', 'way'])
    types.each {|type|
      test_tag_on_real_data_for_this_type(tags, zlevels, old_branch, new_branch, type)
    }
  end

  def self.test_tag_on_real_data_for_this_type(tags, zlevels, old_branch, new_branch, type)
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
    test_tag_on_real_data(tags, zlevels, old_brach, new_branch, types)
  end

  def self.probe(tags, new_branch, old_brach='master', zlevels=Configuration.get_min_z..Configuration.get_max_z, types=['node', 'closed_way', 'way'], test_on_water=false)
    syn_tags = add_common_secondary_tags(tags)
    types.each {|type|
      CartoCSSHelper::VisualDiff.visualise_changes_synthethic_test(syn_tags, type, test_on_water, zlevels, old_brach, new_branch)
    }
  end
end