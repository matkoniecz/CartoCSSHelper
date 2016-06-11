require_relative '../lib/cartocss_helper.rb'
require 'spec_helper'

describe CartoCSSHelper::StyleDataForDefaultOSM do
  it "should not crash" do
    expect(CartoCSSHelper::StyleDataForDefaultOSM.get_style_data).to be_a CartoCSSHelper::StyleSpecificData
  end
end
