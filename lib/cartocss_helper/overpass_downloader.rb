require 'rest-client'
require 'ruby-progressbar'
require_relative 'generic_downloader.rb'
include GenericDownloader

module CartoCSSHelper
  class OverpassDownloader
    class OverpassRefusedResponse < IOError; end

    def self.run_overpass_query(query, _description, _retry_count = 0, _retry_max = 5)
      url = OverpassDownloader.format_query_into_url(query)
      timeout = OverpassDownloader.get_allowed_timeout_in_seconds
      downloader = GenericDownloader.new(timeout: timeout, additional_lethal: [RestClient::RequestTimeout])
      downloader.get_specified_resource(url)
      return String.new(response) # see https://github.com/rest-client/rest-client/issues/370, will be fixed in 2.0 - see https://rubygems.org/gems/rest-client/versions/
    rescue RestClient::RequestTimeout => e
      puts 'Overpass API refused to process this request. It will be not attempted again, most likely query is too complex. It is also possible that Overpass servers are unavailable'
      puts
      puts query
      puts
      puts url
      puts
      puts e
      raise OverpassRefusedResponse
    rescue ArgumentError => e
      puts 'ArgumentError from rest-client, most likely caused by https://github.com/rest-client/rest-client/issues/359'
      puts 'try overpass query that will return smaller amount of data'
      puts query
      puts
      puts url
      puts
      puts e
      e.raise
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
