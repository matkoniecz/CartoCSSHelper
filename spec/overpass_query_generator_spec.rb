# frozen_string_literal: true

require_relative '../lib/cartocss_helper/overpass_query_generator.rb'
require 'spec_helper'

describe CartoCSSHelper::OverpassQueryGenerator do
  it "should handle spaces in tags" do
    expect(CartoCSSHelper::OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter([['a', 'b']])).to eq "\t['a'='b']\n"
    expect(CartoCSSHelper::OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter([['a', 'b b']])).to eq "\t['a'='b b']\n"
    expect(CartoCSSHelper::OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter([['a  ', ' b b ']])).to eq "\t['a  '=' b b ']\n"
  end
  it "should handle quotes in tags" do
    expect(CartoCSSHelper::OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter([['a"', '"""']])).to eq "\t['a\"'='\"\"\"']\n"
    expect(CartoCSSHelper::OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter([["'", "''"]])).to eq "\t['\\''='\\'\\'']\n"
  end
  it "should handle backslashes in tags" do
    expect(CartoCSSHelper::OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter([["surface", "wood\\"]])).to eq "\t['surface'='wood\\\\']\n"
  end
  it "should handle slashes in tags" do
    expect(CartoCSSHelper::OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter([["broken_wikipedia", "https://de.wikipedia.org/wiki/Notruf_der_Autoversicherer"]])).to eq "\t['broken_wikipedia'='https://de.wikipedia.org/wiki/Notruf_der_Autoversicherer']\n"
  end
  it "should handle wildcard - :any_value symbol" do
    expect(CartoCSSHelper::OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter([["surface", :any_value]])).to eq "\t['surface']\n"
  end
  it "can accept tags in dictionaries" do
    expect(CartoCSSHelper::OverpassQueryGenerator.get_query_element_to_get_location({'surface' => 'wood'}, 10, 10, 'node', 100)).to eq "(node['surface'='wood'](around:100,10,10););\n\n"
  end
  it "can accept negations" do
    expect(CartoCSSHelper::OverpassQueryGenerator.get_query_element_to_get_location({'surface' => {:operation => :not_equal_to, :value => 'wood'}}, 10, 10, 'node', 100)).to eq "(node['surface'!='wood'](around:100,10,10););\n\n"
  end
  it "will not escape what needs no escape" do
    expect(CartoCSSHelper::OverpassQueryGenerator.overpass_escape('surface')).to eq "surface"
  end
  it "double quotes will not be escaped as values in a query is surrounded by single quotes" do
    expect(CartoCSSHelper::OverpassQueryGenerator.overpass_escape('"')).to eq '"'
  end
  it "will escape quoyes" do
    backslash = "\\"
    expected = backslash+"'"
    puts(expected.length)
    puts(CartoCSSHelper::OverpassQueryGenerator.overpass_escape("'").length)
    expect(CartoCSSHelper::OverpassQueryGenerator.overpass_escape("'")).to eq expected
  end
end
