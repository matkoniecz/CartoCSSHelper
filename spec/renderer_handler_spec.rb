require_relative '../lib/cartocss_helper.rb'
require 'spec_helper'

describe CartoCSSHelper::StyleDataForDefaultOSM do
  it "to return quickly on available cache" do
    allow(File).to receive(:exist?).and_return(true)
    cache_folder = "/dev/null/"
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_folder_for_branch_specific_cache).and_return(cache_folder)
    renderer = 'renderer'
    allow(CartoCSSHelper::Configuration).to receive(:renderer).and_return(renderer)
    filename = 'outpuiaj89jv8hwt.png'
    expect(CartoCSSHelper::RendererHandler.request_image_from_renderer(0, 0, 20..20, [1, 1], 10, filename)).to eq cache_folder + renderer + '_mapnik_reference=default_' + filename
  end

  it "to return on success" do
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_cartocss_project_folder).and_return("/dev/null")
    cache_folder = "/dev/null/"
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_folder_for_branch_specific_cache).and_return(cache_folder)
    allow(CartoCSSHelper::Git).to receive(:get_commit_hash).and_return("r643646")

    allow(File).to receive(:exist?).and_return(false, true)
    allow(CartoCSSHelper::RendererHandler).to receive(:execute_command).and_return("")

    renderer = 'renderer'
    allow(CartoCSSHelper::Configuration).to receive(:renderer).and_return(renderer)

    filename = 'outpuiaj89jv8hwt.png'

    expect(CartoCSSHelper::RendererHandler.request_image_from_renderer(0, 0, 20..20, [1, 1], 10, filename)).to eq cache_folder + renderer + '_mapnik_reference=default_' + filename
  end

  it "to return on success with default renderer" do
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_cartocss_project_folder).and_return("/dev/null")
    cache_folder = "/dev/null/"
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_folder_for_branch_specific_cache).and_return(cache_folder)
    allow(CartoCSSHelper::Git).to receive(:get_commit_hash).and_return("r643646")

    allow(File).to receive(:exist?).and_return(false, true)
    allow(CartoCSSHelper::RendererHandler).to receive(:execute_command).and_return("")

    filename = 'outpuiaj89jv8hwt.png'

    expect(CartoCSSHelper::RendererHandler.request_image_from_renderer(0, 0, 20..20, [1, 1], 10, filename)).to eq cache_folder + 'tilemill' + '_mapnik_reference=default_' + filename
  end

  it "on silently failed generation emits exception and shows output from executed command" do
    allow(File).to receive(:exist?).and_return(false)
    output = "error kill six billion demons"
    allow(CartoCSSHelper::RendererHandler).to receive(:execute_command).and_return(output)
    allow(CartoCSSHelper::Git).to receive(:get_commit_hash).and_return("r643646")
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_cartocss_project_folder).and_return("/dev/null")
    cache_folder = "/dev/null/"
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_folder_for_branch_specific_cache).and_return(cache_folder)
    expect { CartoCSSHelper::RendererHandler.request_image_from_renderer(0, 0, 20..20, [1, 1], 10, 'outpuiaj89jv8hwt.png') }.to raise_error CartoCSSHelper::RendererFailedToGenerateFile
    begin
      CartoCSSHelper::RendererHandler.request_image_from_renderer(0, 0, 20..20, [1, 1], 10, 'outpuiaj89jv8hwt.png')
    rescue CartoCSSHelper::RendererFailedToGenerateFile => e
      expect(e.to_s.include?(output)).to eq true
    end
  end

  it "on silently failed generation emits exception and shows output from executed command" do
    allow(File).to receive(:exist?).and_return(false)
    allow(CartoCSSHelper::RendererHandler).to receive(:execute_command).and_raise(FailedCommandException)
    allow(CartoCSSHelper::Git).to receive(:get_commit_hash).and_return("r643646")
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_cartocss_project_folder).and_return("/dev/null")
    cache_folder = "/dev/null/"
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_folder_for_branch_specific_cache).and_return(cache_folder)
    expect { CartoCSSHelper::RendererHandler.request_image_from_renderer(0, 0, 20..20, [1, 1], 10, 'outpuiaj89jv8hwt.png') }.to raise_error CartoCSSHelper::RendererFailedToGenerateFile
  end

  it "allows to check for presense of cache" do
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_cartocss_project_folder).and_return("/dev/null")
    cache_folder = "/dev/null/"
    allow(CartoCSSHelper::Configuration).to receive(:get_path_to_folder_for_branch_specific_cache).and_return(cache_folder)

    allow(File).to receive(:exist?).and_return(false)
    filename = 'zażółć_gęślą_jaźń.png'
    expect(CartoCSSHelper::RendererHandler.image_available_from_cache(0, 0, 20..20, [1, 1], 10, filename)).to eq false
    allow(File).to receive(:exist?).and_return(true)
    expect(CartoCSSHelper::RendererHandler.image_available_from_cache(0, 0, 20..20, [1, 1], 10, filename)).to eq true
  end
end
