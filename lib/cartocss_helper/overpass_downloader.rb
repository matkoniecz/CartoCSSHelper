require_relative 'generic_downloader.rb'
require 'uri' # for URI.escape

module CartoCSSHelper
  class OverpassDownloader
    class OverpassRefusedResponse < IOError; end

    def self.run_overpass_query(query, _description, _retry_count = 0, _retry_max = 5)
      url = OverpassDownloader.format_query_into_url(query)
      timeout = OverpassDownloader.get_allowed_timeout_in_seconds
      downloader = GenericDownloader.new(timeout: timeout, retry_on_timeout: false)
      return downloader.get_specified_resource(url)
    rescue GenericDownloader::RequestTimeout => e
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
      query = query.gsub(/\n/, '')
      query = query.gsub(/\t/, '')
      base_overpass_url = OverpassDownloader.get_overpass_instance_url
      return base_overpass_url + '/interpreter?data=' + URI.escape(query)
    end

    def self.get_overpass_instance_url
      return CartoCSSHelper::Configuration.get_overpass_instance_url
    end
  end
end
