# frozen_string_literal: true

require_relative '../lib/cartocss_helper.rb'
require 'spec_helper'

describe CartoCSSHelper::Scene do
  it "should not crash" do
    scene = CartoCSSHelper::Scene.new({}, 10, false, 'way', false)
  end
end
