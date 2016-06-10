require 'ruby-progressbar'

module GenericDownloader
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

  def get_specified_resource(url, timeout: 20, error_message: nil, retry_count: 0, retry_max: 5, additional_lethal: [])
    lethal_exceptions = [URI::InvalidURIError, RestClient::ResourceNotFound] + additional_lethal
    begin
      data = RestClient::Request.execute(method: :get, url: url, timeout: timeout)
    rescue SocketError. URI::InvalidURIError => e
      output_shared_error_part(error_message, url, e)
      wait
      if retry_count > retry_max || lethal_exceptions.include?(e.class)
        raise e
      else
        get_specified_resource(url, timeout: timeout, error_message: error_message, retry_count: retry_count + 1, additional_lethal: additional_lethal)
      end
    rescue RestClient::RequestFailed, RestClient::ServerBrokeConnection, RestClient::ResourceNotFound => e
      output_shared_error_part(error_message, url, e)
      puts e.response
      puts e.http_code
      wait
      if retry_count > retry_max || lethal_exceptions.include?(e.class)
        raise e
      else
        get_specified_resource(url, timeout: timeout, error_message: error_message, retry_count: retry_count + 1, additional_lethal: additional_lethal)
      end
    rescue ArgumentError => e
      output_shared_error_part(error_message, url, e)
      puts 'ArgumentError from rest-client, most likely caused by https://github.com/rest-client/rest-client/issues/359'
    rescue => e
      puts 'unhandled exception! It is a clear bug!'
      output_shared_error_part(error_message, url, e)
      wait
      puts "<#{e.class} error happened>"
      e.raise
    end
    # see https://github.com/rest-client/rest-client/issues/370, will be fixed in 2.0
    # published versions listed on https://rubygems.org/gems/rest-client/versions/
    return String.new(data)
  end
end
