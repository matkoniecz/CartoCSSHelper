require_relative '../lib/cartocss_helper.rb'
require 'spec_helper'

class InfiniteFailMockClientWrapper
  def fetch_data_from_url(_url, _request_timeout)
    raise ExceptionWithoutResponse
  end
end

class InfiniteFailResponseMockClientWrapper
  def fetch_data_from_url(_url, _request_timeout)
    raise ExceptionWithResponse
  end
end

class Infinite429ResponseMockClientWrapper
  def fetch_data_from_url(_url, _request_timeout)
    e = ExceptionWithResponse.new
    e.http_code = 429
    raise e
  end
end

class ReliableMockClientWrapper
  def fetch_data_from_url(_url, _request_timeout)
    return ""
  end
end

describe GenericDownloader do
  it "should initialize" do
    expect(GenericDownloader.new)
  end
  it "should accepted all args (timeout, error_message, stop_on_timeout, wrapper)" do
    downloader = GenericDownloader.new(timeout: 0, error_message: nil, stop_on_timeout: true, wrapper: ReliableMockClientWrapper.new)
    expect(downloader.get_specified_resource("")).to eq ""
  end
  it "should accepted all args in any order" do
    downloader = GenericDownloader.new(timeout: 0, error_message: nil, wrapper: ReliableMockClientWrapper.new, stop_on_timeout: true)
    expect(downloader.get_specified_resource("")).to eq ""
  end
  it "should accepted part of args" do
    downloader = GenericDownloader.new(error_message: nil, wrapper: ReliableMockClientWrapper.new)
    expect(downloader.get_specified_resource("")).to eq ""
  end
  it "should work" do
    downloader = GenericDownloader.new(wrapper: ReliableMockClientWrapper.new)
    expect(downloader.get_specified_resource("")).to eq ""
  end
  it "should not loop forever" do
    downloader = GenericDownloader.new(wrapper: InfiniteFailMockClientWrapper.new)
    expect { downloader.get_specified_resource("") }.to raise_error ExceptionWithoutResponse
  end
  it "should not loop forever" do
    downloader = GenericDownloader.new(wrapper: InfiniteFailResponseMockClientWrapper.new)
    expect { downloader.get_specified_resource("aaa") }.to raise_error ExceptionWithResponse
  end
  it "should not loop forever" do
    downloader = GenericDownloader.new(wrapper: Infinite429ResponseMockClientWrapper.new)
    expect { downloader.get_specified_resource("aaa") }.to raise_error ExceptionWithResponse
  end
end
