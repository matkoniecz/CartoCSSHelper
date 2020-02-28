# frozen_string_literal: true

require_relative '../lib/cartocss_helper/overpass_downloader.rb'
require 'spec_helper'

describe CartoCSSHelper::OverpassDownloader do
  it "should escape slashes in query text" do
    expect(CartoCSSHelper::OverpassDownloader.escape_query("https://de.wikipedia.org")).to eq "https:%2F%2Fde.wikipedia.org"
  end
  it "should escape spaces in query text" do
    expect(CartoCSSHelper::OverpassDownloader.escape_query(" ")).to eq "%20"
  end

end
