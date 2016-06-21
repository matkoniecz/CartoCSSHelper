require_relative '../lib/cartocss_helper.rb'
require 'spec_helper'

describe CartoCSSHelper::StyleDataForDefaultOSM do
  it "to return quickly on available cache" do
    allow(File).to receive(:exist?).and_return(true)
    expect(CartoCSSHelper::TilemillHandler.run_tilemill_export_image(0, 0, 20..20, [1, 1], 10, 'outpuiaj89jv8hwt.png')).to eq nil
  end

  it "on silently failed generation emits exception and shows output from executed command" do
    allow(File).to receive(:exist?).and_return(false)
    output = "error kill six billion demons"
    allow(CartoCSSHelper::TilemillHandler).to receive(:execute_command).and_return(output)
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_tilemill_project_folder).and_return("/dev/null")
    expect { CartoCSSHelper::TilemillHandler.run_tilemill_export_image(0, 0, 20..20, [1, 1], 10, 'outpuiaj89jv8hwt.png') }.to raise_error CartoCSSHelper::TilemillFailedToGenerateFile
    begin
      CartoCSSHelper::TilemillHandler.run_tilemill_export_image(0, 0, 20..20, [1, 1], 10, 'outpuiaj89jv8hwt.png')
    rescue CartoCSSHelper::TilemillFailedToGenerateFile => e
      expect(e.to_s.include?(output)).to eq true
    end
  end

  it "on silently failed generation emits exception and shows output from executed command" do
    allow(File).to receive(:exist?).and_return(false)
    allow(CartoCSSHelper::TilemillHandler).to receive(:execute_command).and_raise(FailedCommandException)
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_tilemill_project_folder).and_return("/dev/null")
    expect { CartoCSSHelper::TilemillHandler.run_tilemill_export_image(0, 0, 20..20, [1, 1], 10, 'outpuiaj89jv8hwt.png') }.to raise_error CartoCSSHelper::TilemillFailedToGenerateFile
  end

end
