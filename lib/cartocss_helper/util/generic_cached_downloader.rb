require_relative 'generic_downloader.rb'

class GenericCachedDownloader
  def initialize(timeout: 20, error_message: nil, stop_on_timeout: true, wrapper: RestClientWrapper.new)
    @request_timeout = timeout
    @error_message = error_message
    @stop_on_timeout = stop_on_timeout
    @wrapper = wrapper
  end

  def get_specified_resource(url, cache_filename, description: nil)
    cache = read_from_cache(cache_filename)
    return cache if cache != nil
    response = download(url, description)
    write_cache(response, cache_filename)

    return response
  end

  def read_from_cache(cache_filename)
    if File.exist?(cache_filename)
      file = File.new(cache_filename)
      cached = file.read
      file.close
      return cached
    end
    return nil
  end

  def download(url, description)
    downloader = GenericDownloader.new(timeout: @request_timeout, error_message: @error_message, stop_on_timeout: @stop_on_timeout, wrapper: @wrapper)
    return downloader.get_specified_resource(url, description: description)
  end

  def write_cache(response, cache_filename)
    file = File.new(cache_filename, 'w')
    file.write response
    file.close
  end
end