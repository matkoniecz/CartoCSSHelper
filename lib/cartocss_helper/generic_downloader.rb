require 'ruby-progressbar'
require 'rest-client'

class GenericDownloader
  class ResourcePernamentlyUnavailable < StandardError
  end

  class RequestTimeout < StandardError
  end

  def initialize(timeout: 20, error_message: nil, retry_on_timeout: true)
    @timeout = timeout
    @retry_count = 0
    @error_message = error_message
    @lethal_exceptions = [URI::InvalidURIError, RestClient::ResourceNotFound]
    @lethal_exceptions += [RequestTimeout] if retry_on_timeout == false
  end

  def max_retry_count
    5
  end

  def wait
    progressbar = ProgressBar.create
    100.times do
      sleep 4
      progressbar.increment
    end
  end

  def output_shared_error_part(url, e)
    puts @error_message unless @error_message.nil?
    puts
    puts url
    puts
    puts e.class
    puts e
  end

  def retry_allowed(exception)
    if retry_count > retry_max || @lethal_exceptions.include?(exception.class)
      raise exception
    end
    wait
    @retry_count += 1
  end

  def get_specified_resource(url)
    return fetch_data_from_url_using_rest_client(url)
  rescue SocketError, URI::InvalidURIError => e
    output_shared_error_part(url, e)
    get_specified_resource(url) if retry_allowed(e)
  rescue RequestTimeout, RestClient::RequestFailed, RestClient::ServerBrokeConnection, RestClient::ResourceNotFound => e
    output_shared_error_part(url, e)
    puts e.response
    puts e.http_code
    get_specified_resource(url) if retry_allowed(e)
  rescue ArgumentError => e
    output_shared_error_part(url, e)
    raise ResourcePernamentlyUnavailable, 'ArgumentError from rest-client, most likely caused by https://github.com/rest-client/rest-client/issues/359 (requesting GBs of data)'
  rescue => e
    puts 'unhandled exception! It is a clear bug!'
    output_shared_error_part(url, e)
    puts "<#{e.class} error happened>"
    raise e
  end

  def fetch_data_from_url_using_rest_client(url)
    data = RestClient::Request.execute(method: :get, url: url, timeout: timeout)
    # see https://github.com/rest-client/rest-client/issues/370, will be fixed in 2.0
    # published versions listed on https://rubygems.org/gems/rest-client/versions/
    return String.new(data)
  rescue RestClient::RequestTimeout => e
    raise RequestTimeout, e
  end
end
