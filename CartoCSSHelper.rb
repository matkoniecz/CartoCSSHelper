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
  def test_tag_on_real_data(tags, zlevels, old_branch, new_branch)
    #special support for following tag values:  :any_value
    krakow_latitude = 50.1
    krakow_longitude = 19.9
    VisualDiff.visualise_changes_on_real_data(tags, krakow_latitude, krakow_longitude, zlevels, old_branch, new_branch)
    japan_latitude = 36.1
    japan_longitude = 140.7
    VisualDiff.visualise_changes_on_real_data(tags, japan_latitude, japan_longitude, zlevels, old_branch, new_branch)
    russia_latitude = 54.8
    russia_longitude = 31.7
    VisualDiff.visualise_changes_on_real_data(tags, russia_latitude, russia_longitude, zlevels, old_branch, new_branch)
    mecca_latitude = 21.3
    mecca_longitude = 39.5
    VisualDiff.visualise_changes_on_real_data(tags, mecca_latitude, mecca_longitude, zlevels, old_branch, new_branch)
    georgia_latitude = 41.4
    georgia_longitude = 44.5
    VisualDiff.visualise_changes_on_real_data(tags, georgia_latitude, georgia_longitude, zlevels, old_branch, new_branch)
    london_latitude = 51.5
    london_longitude = -0.1
    VisualDiff.visualise_changes_on_real_data(tags, london_latitude, london_longitude, zlevels, old_branch, new_branch)
    utrecht_latitude =  52.09
    utrecht_longitude = 5.11
    VisualDiff.visualise_changes_on_real_data(tags, london_latitude, london_longitude, zlevels, old_branch, new_branch)
  end

  def add_common_secondary_tags(tags)
    return tags.merge({'name' => 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ', 'ref' => '1', 'ele' => '8000'})
  end

  def test(tags, type, zlevels, new_branch, old_brach='master')
    puts "processing #{VisualDiff.dict_to_pretty_tag_list(tags)}"
    zlevels_for_synthetic = Configuration.get_min_z..Configuration.get_max_z
    syn_tags = add_common_secondary_tags(tags)
    VisualDiff.visualise_changes_synthethic_test(syn_tags, type, false, zlevels_for_synthetic, old_brach, new_branch)
    test_tag_on_real_data(tags, zlevels, old_brach, new_branch)
  end

  def probe(tags, type, zlevels, new_branch, old_brach='master')
    zlevels_for_synthetic = Configuration.get_min_z..Configuration.get_max_z
    syn_tags = add_common_secondary_tags(tags)
    VisualDiff.visualise_changes_synthethic_test(syn_tags, type, false, zlevels_for_synthetic, old_brach, new_branch)
  end

end
