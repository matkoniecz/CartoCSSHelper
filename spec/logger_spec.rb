# frozen_string_literal: true

require_relative '../lib/cartocss_helper/util/logger.rb'
require 'spec_helper'

describe Log do
  it "should have log that is not crashing" do
    message = "zażółć gęślą jaźń"
    Log.info(message)
    Log.warn(message)
  end
end
