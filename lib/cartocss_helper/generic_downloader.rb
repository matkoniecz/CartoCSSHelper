require 'ruby-progressbar'

class GenericDownloader
  def initialize(timeout: 20, error_message: nil, additional_lethal: [])
    @timeout = timeout
    @retry_count = 0
    @error_message = error_message
    @lethal_exceptions = [URI::InvalidURIError, RestClient::ResourceNotFound] + additional_lethal
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

  def output_shared_error_part(error_message, url, e)
    puts error_message unless error_message.nil?
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
    @retry_count += 1
  end

  def get_specified_resource(url)
    data = RestClient::Request.execute(method: :get, url: url, timeout: timeout)
    # see https://github.com/rest-client/rest-client/issues/370, will be fixed in 2.0
    # published versions listed on https://rubygems.org/gems/rest-client/versions/
    return String.new(data)
  rescue SocketError, URI::InvalidURIError => e
    output_shared_error_part(error_message, url, e)
    wait
    get_specified_resource(url) if retry_allowed(e)
  rescue RestClient::RequestFailed, RestClient::ServerBrokeConnection, RestClient::ResourceNotFound => e
    output_shared_error_part(error_message, url, e)
    puts e.response
    puts e.http_code
    wait
    get_specified_resource(url) if retry_allowed(e)
  rescue ArgumentError => e
    output_shared_error_part(error_message, url, e)
    puts 'ArgumentError from rest-client, most likely caused by https://github.com/rest-client/rest-client/issues/359'
    raise e
  rescue => e
    puts 'unhandled exception! It is a clear bug!'
    output_shared_error_part(error_message, url, e)
    wait
    puts "<#{e.class} error happened>"
    raise e
  end
end
