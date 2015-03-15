# encoding: UTF-8
require 'open3'

module CartoCSSHelper
end
load 'tag_lister.rb'
load 'visualise_changes_image_generation.rb'
load 'downloader.rb'
load 'data_file_handling.rb'
load 'validator.rb'
load 'git.rb'
include CartoCSSHelper::Validator
include CartoCSSHelper::Git

module CartoCSSHelper
  def self.test_tag_on_real_data(tags, zlevels, old_branch, new_branch, type)
    #special support for following tag values:  :any_value
    krakow_latitude = 50.1
    krakow_longitude = 19.9
    VisualDiff.visualise_changes_on_real_data(tags, type, krakow_latitude, krakow_longitude, zlevels, old_branch, new_branch)
    japan_latitude = 36.1
    japan_longitude = 140.7
    VisualDiff.visualise_changes_on_real_data(tags, type, japan_latitude, japan_longitude, zlevels, old_branch, new_branch)
    russia_latitude = 54.8
    russia_longitude = 31.7
    VisualDiff.visualise_changes_on_real_data(tags, type, russia_latitude, russia_longitude, zlevels, old_branch, new_branch)
    mecca_latitude = 21.3
    mecca_longitude = 39.5
    VisualDiff.visualise_changes_on_real_data(tags, type, mecca_latitude, mecca_longitude, zlevels, old_branch, new_branch)
    georgia_latitude = 41.4
    georgia_longitude = 44.5
    VisualDiff.visualise_changes_on_real_data(tags, type, georgia_latitude, georgia_longitude, zlevels, old_branch, new_branch)
    london_latitude = 51.5
    london_longitude = -0.1
    VisualDiff.visualise_changes_on_real_data(tags, type, london_latitude, london_longitude, zlevels, old_branch, new_branch)
    #TODO: solve problems with respons to big to store in memory
    #utrecht_latitude =  52.09
    #utrecht_longitude = 5.11
    #VisualDiff.visualise_changes_on_real_data(tags, type, utrecht_latitude, utrecht_longitude, zlevels, old_branch, new_branch)
    rural_uk_latitude =  53.2
    rural_uk_longitude = -1.8
    VisualDiff.visualise_changes_on_real_data(tags, type, rural_uk_latitude, rural_uk_longitude, zlevels, old_branch, new_branch)
  end

  def self.add_common_secondary_tags(tags)
    return tags.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000'})
  end

  def self.test(tags, type, zlevels, new_branch, old_brach='master')
    puts "processing #{VisualDiff.dict_to_pretty_tag_list(tags)}"
    zlevels_for_synthetic = Configuration.get_min_z..Configuration.get_max_z
    syn_tags = add_common_secondary_tags(tags)
    VisualDiff.visualise_changes_synthethic_test(syn_tags, type, false, zlevels_for_synthetic, old_brach, new_branch)
    test_tag_on_real_data(tags, zlevels, old_brach, new_branch, type)
  end

  def self.probe(tags, type, zlevels, new_branch, old_brach='master')
    zlevels_for_synthetic = Configuration.get_min_z..Configuration.get_max_z
    syn_tags = add_common_secondary_tags(tags)
    VisualDiff.visualise_changes_synthethic_test(syn_tags, type, false, zlevels_for_synthetic, old_brach, new_branch)
  end

end
