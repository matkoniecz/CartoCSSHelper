require_relative '../lib/cartocss_helper.rb'
require 'spec_helper'

describe CartoCSSHelper do
  it "should not crash during download_remote_file" do
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_cartocss_project_folder).and_return("/dev/null")
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_folder_for_overpass_cache).and_return("/dev/null")
    allow_any_instance_of(GenericCachedDownloader).to receive(:get_specified_resource).and_return("Wibble")
    CartoCSSHelper.download_remote_file('www.example.com')
  end

  it "should return correct value for get_latitude_longitude_from_url, also with negatives" do
    expect(CartoCSSHelper.get_latitude_longitude_from_url("http://www.openstreetmap.org/#map=6/47.234/-3.911")).to eq [47.234, -3.911]
  end

  it "should return correct value for get_latitude_longitude_from_url, also with two negatives" do
    expect(CartoCSSHelper.get_latitude_longitude_from_url("http://www.openstreetmap.org/#map=6/-47.234/-3.911")).to eq [-47.234, -3.911]
  end

  it "should return correct value for get_latitude_longitude_from_url, also during displaying an object" do
    expect(CartoCSSHelper.get_latitude_longitude_from_url("http://www.openstreetmap.org/way/94450744#map=19/54.77389/31.78849")).to eq [54.77389, 31.78849]
  end

  it "should return correct value for get_latitude_longitude_from_url, also during displaying an add note widget" do
    expect(CartoCSSHelper.get_latitude_longitude_from_url("http://www.openstreetmap.org/note/new#map=19/54.77406/31.78858&layers=N")).to eq [54.77406, 31.78858]
  end

  it "prefer pinned location over map location" do
    expect(CartoCSSHelper.get_latitude_longitude_from_url("http://www.openstreetmap.org/?mlat=54.77442&mlon=-31.78703#map=7/55.292/6.229")).to eq [54.77442, -31.78703]
  end

  it "should have plenty of testing locations" do
    expect(CartoCSSHelper.get_list_of_testing_locations.count).to be > 100
    expect(CartoCSSHelper.get_maxn_for_nth_location).to be > 100
  end

  it "should have plenty of different testing locations" do
    (1..CartoCSSHelper.get_maxn_for_nth_location).each do |n|
      expect(CartoCSSHelper.get_nth_location(n)).to_not be CartoCSSHelper.get_nth_location(n - 1)
    end
  end

  it "should report correct number testing locations" do
    n = CartoCSSHelper.get_maxn_for_nth_location + 1
    expect(CartoCSSHelper.get_nth_location(n)).to be nil
  end
end
