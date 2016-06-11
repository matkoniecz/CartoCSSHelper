require 'ruby-progressbar'
require_relative 'rest-client_wrapper.rb'

class BuggyRestClient < StandardError
end

class ExceptionWithResponse < StandardError
  attr_accessor :http_code, :response
end

class ExceptionWithoutResponse < StandardError
  attr_accessor :http_code, :response
end

class RequestTimeout < StandardError
end

class GenericDownloader
  def initialize(timeout: 20, error_message: nil, stop_on_timeout: true, wrapper: RestClientWrapper.new)
    @request_timeout = timeout
    @retry_count = 0
    @error_message = error_message
    @stop_on_timeout = stop_on_timeout
    @wrapper = wrapper
  end

  def max_retry_count
    5
  end

  def output_shared_error_part(url, e)
    puts @error_message unless @error_message.nil?
    puts
    puts url
    puts
    puts e.class
    puts e
  end

  def retry_allowed(exception_with_response)
    raise exception_with_response if @retry_count > max_retry_count
    if @stop_on_timeout
      raise exception_with_response if exception_with_response.is_a?(RequestTimeout)
    end
    if [429, 503].include?(exception_with_response.http_code)
      @retry_count += 1
      return true
    end
    raise exception_with_response
  end

  def get_specified_resource(url)
    return @wrapper.fetch_data_from_url(url, @request_timeout)
  rescue ExceptionWithResponse => e
    output_shared_error_part(url, e)
    puts e.response
    puts e.http_code
    get_specified_resource(url) if retry_allowed(e)
  rescue ExceptionWithoutResponse => e
    output_shared_error_part(url, e)
    raise e
  end
end
