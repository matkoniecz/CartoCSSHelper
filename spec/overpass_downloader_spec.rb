# frozen_string_literal: true

require_relative '../lib/cartocss_helper/overpass_downloader.rb'
require 'spec_helper'

describe CartoCSSHelper::OverpassDownloader do
  it "should handle slashes in query text" do
    expect(CartoCSSHelper::OverpassDownloader.escape_query("https://de.wikipedia.org")).to eq "https:%2F%2Fde.wikipedia.org"
  end
end
