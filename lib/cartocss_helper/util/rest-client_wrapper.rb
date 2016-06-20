require 'rest-client'
require_relative 'generic_downloader.rb'

class RestClientWrapper
  def initialize
    @last_url_fetched = nil
  end

  def fetch_data_from_url(url, request_timeout)
    wait if url == @last_url_fetched
    @last_url_fetched = url
    return execute_fetch_data_from_url(url, request_timeout)
  # http://www.rubydoc.info/gems/rest-client/1.8.0/RestClient/Exception
  rescue RestClient::RequestTimeout => e
    raise RequestTimeout, e.to_s
  rescue RestClient::ExceptionWithResponse => e
    raise_exception_about_returned_response(e)
  rescue RestClient::MaxRedirectsReached, RestClient::SSLCertificateNotVerified, RestClient::ServerBrokeConnection, SocketError, URI::InvalidURIError
    raise ExceptionWithoutResponse.new(e), e.to_s
  rescue ArgumentError => e
    raise_issue_359_exception(e)
  rescue => e
    puts 'unhandled exception! It is a clear bug!'
    puts "<#{e.class} error happened>"
    raise e, e.to_s
  end

  def execute_fetch_data_from_url(url, request_timeout)
    data = RestClient::Request.execute(method: :get, url: url, timeout: request_timeout)
    # see https://github.com/rest-client/rest-client/issues/370, will be fixed in 2.0
    # published versions listed on https://rubygems.org/gems/rest-client/versions/
    return String.new(data)
  end

  def raise_issue_359_exception(e)
    raise BuggyRestClient, "ArgumentError from rest-client, most likely caused by https://github.com/rest-client/rest-client/issues/359 (requesting GBs of data) [#{e}]"
  end

  def raise_exception_about_returned_response(e)
    failure = ExceptionWithResponse.new(e)
    failure.http_code = e.http_code
    failure.response = e.response
    raise failure, e.to_s
  end

  def wait
    progressbar = ProgressBar.create
    100.times do
      sleep 4
      progressbar.increment
    end
  end
end
