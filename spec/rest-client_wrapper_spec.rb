require_relative '../lib/cartocss_helper.rb'
require 'spec_helper'

class UnexpectedRidiculousExceptions < StandardError
end

describe RestClientWrapper do
  it "should initialize" do
    expect(RestClientWrapper.new)
  end

  it "should work for happy case" do
    a = RestClientWrapper.new
    data = "data"
    allow(RestClient::Request).to receive(:execute).and_return(data)
    expect(a.fetch_data_from_url("url", 1)).to eq data
  end

  it "should raise BuggyRestClient on ArgumentError from rest-client caused by https://github.com/rest-client/rest-client/issues/359" do
    a = RestClientWrapper.new
    allow(RestClient::Request).to receive(:execute).and_raise(ArgumentError)
    expect { a.fetch_data_from_url("url", 1) }.to raise_error BuggyRestClient
  end

  it "should raise ExceptionWithResponse on RestClient::ExceptionWithResponse emitted by RestClient" do
    a = RestClientWrapper.new
    allow(RestClient::Request).to receive(:execute).and_raise(RestClient::ExceptionWithResponse)
    expect { a.fetch_data_from_url("url", 1) }.to raise_error ExceptionWithResponse
  end

  it "should raise RequestTimeout on RequestTimeout::ExceptionWithResponse emitted by RestClient" do
    a = RestClientWrapper.new
    allow(RestClient::Request).to receive(:execute).and_raise(RestClient::RequestTimeout)
    expect { a.fetch_data_from_url("url", 1) }.to raise_error RequestTimeout
  end

  it "should not silently eat unexpected exceptions emitted by RestClient" do
    a = RestClientWrapper.new
    allow(RestClient::Request).to receive(:execute).and_raise(UnexpectedRidiculousExceptions)
    expect { a.fetch_data_from_url("url", 1) }.to raise_error UnexpectedRidiculousExceptions
  end
end
