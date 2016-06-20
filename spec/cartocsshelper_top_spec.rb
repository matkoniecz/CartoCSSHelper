require_relative '../lib/cartocss_helper.rb'
require 'spec_helper'

describe CartoCSSHelper do
  it "should not crash" do
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_tilemill_project_folder).and_return("/dev/null")
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_folder_for_overpass_cache).and_return("/dev/null")
    allow_any_instance_of(GenericCachedDownloader).to receive(:get_specified_resource).and_return("Wibble")
    CartoCSSHelper.download_remote_file('www.example.com')
  end
end
