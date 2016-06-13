require_relative '../lib/cartocss_helper.rb'
require 'spec_helper'

describe CartoCSSHelper::StyleDataForDefaultOSM do
  it "to return quickly on available cache" do
    allow(File).to receive(:exist?).and_return(true)
    expect(CartoCSSHelper::TilemillHandler.run_tilemill_export_image(0, 0, 20..20, [1, 1], 10, 'outpuiaj89jv8hwt.png')).to eq nil
  end
  it "to crash on failed generation" do
    allow(File).to receive(:exist?).and_return(false)
    allow(CartoCSSHelper::TilemillHandler).to receive(:execute_command).and_return("")
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_tilemill_project_folder).and_return("/dev/null")
    expect { CartoCSSHelper::TilemillHandler.run_tilemill_export_image(0, 0, 20..20, [1, 1], 10, 'outpuiaj89jv8hwt.png') }.to raise_error CartoCSSHelper::TilemillFailedToGenerateFile
  end
end
