require_relative 'util/generic_downloader.rb'
require_relative 'util/generic_cached_downloader.rb'
require 'uri' # for URI.escape

module CartoCSSHelper
  class OverpassDownloader
    class OverpassRefusedResponse < IOError; end

    def self.run_overpass_query(query, description, cache_filename)
      url = OverpassDownloader.format_query_into_url(query)
      timeout = OverpassDownloader.get_allowed_timeout_in_seconds
      downloader = GenericCachedDownloader.new(timeout: timeout, stop_on_timeout: false)
      return downloader.get_specified_resource(url, cache_filename, description: description)
    rescue RequestTimeout => e
      puts 'Overpass API refused to process this request. It will be not attempted again, most likely query is too complex. It is also possible that Overpass servers are unavailable'
      puts
      puts query
      puts
      puts url
      puts
      puts e
      raise OverpassRefusedResponse
    end

    def self.get_allowed_timeout_in_seconds
      return 10 * 60
    end

    def self.format_query_into_url(query)
      query = query.delete("\n")
      query = query.delete("\t")
      base_overpass_url = OverpassDownloader.get_overpass_instance_url
      return base_overpass_url + '/interpreter?data=' + URI.escape(query)
    end

    def self.get_overpass_instance_url
      return CartoCSSHelper::Configuration.get_overpass_instance_url
    end
  end
end
