# frozen_string_literal: true

require 'ruby-progressbar'
require_relative 'rest-client_wrapper.rb'
require_relative 'logger.rb'

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
    Log.warn @error_message unless @error_message.nil?
    Log.warn
    Log.warn url
    Log.warn
    Log.warn e.class
    Log.warn e
  end

  def retry_allowed(exception_with_response)
    raise exception_with_response if @retry_count > max_retry_count
    if @stop_on_timeout
      raise exception_with_response if exception_with_response.is_a?(RequestTimeout)
    end
    if [429, 503, 504].include?(exception_with_response.http_code)
      @retry_count += 1
      return true
    end
    raise exception_with_response
  end

  def get_specified_resource(url, description: nil)
    Log.info description if description
    return @wrapper.fetch_data_from_url(url, @request_timeout)
  rescue ExceptionWithResponse => e
    output_shared_error_part(url, e)
    Log.warn e.response
    Log.warn e.http_code
    if retry_allowed(e)
      get_specified_resource(url)
    else
      raise e
    end
  rescue ExceptionWithoutResponse => e
    output_shared_error_part(url, e)
    raise e
  end
end
