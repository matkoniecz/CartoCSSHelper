# frozen_string_literal: true

require_relative 'util/generic_downloader.rb'
require_relative 'util/generic_cached_downloader.rb'
require 'uri' # for URI.escape
require 'digest/sha1'

module CartoCSSHelper
  class OverpassDownloader
    class OverpassRefusedResponse < IOError; end

    def self.cache_filename(query)
      hash = Digest::SHA1.hexdigest query
      query_cache_filename = CartoCSSHelper::Configuration.get_path_to_folder_for_overpass_cache + hash + '_query.cache'
      return query_cache_filename
    end

    def self.cache_timestamp(query)
      downloader = GenericCachedDownloader.new
      return downloader.get_cache_timestamp(cache_filename(query))
    end

    def self.run_overpass_query(query, description, invalidate_cache: false)
      url = OverpassDownloader.format_query_into_url(query)
      timeout = OverpassDownloader.get_allowed_timeout_in_seconds
      downloader = GenericCachedDownloader.new(timeout: timeout, stop_on_timeout: false)
      return downloader.get_specified_resource(url, cache_filename(query), description: description, invalidate_cache: invalidate_cache)
    rescue RequestTimeout => e
      puts 'Overpass API refused to process this request. It will be not attempted again, most likely query is too complex. It is also possible that Overpass servers are unavailable'
      puts
      puts query
      puts
      puts url
      puts
      puts e
      raise OverpassRefusedResponse
    rescue ExceptionWithResponse => e
      if e.http_code == 400
        puts "invalid query"
        puts
        puts query
        puts
        puts url
        puts
        puts e
      elsif e.http_code == 414
        puts 'see https://github.com/matkoniecz/CartoCSSHelper/issues/35'
      end
      raise e
    end

    def self.get_allowed_timeout_in_seconds
      return 10 * 60
    end

    def self.format_query_into_url(query)
      query = query.gsub(/\/\/.*\n/, '') # add proper parsing - it will mutilate // inside quotes etc
      query = query.gsub('\\', '\\\\')
      query = query.delete("\n")
      query = query.delete("\t")
      if query.length > 8174 #8175 is too much and allows crashes
        raise 'see https://github.com/matkoniecz/CartoCSSHelper/issues/35'
      end
      base_overpass_url = OverpassDownloader.get_overpass_instance_url
      return base_overpass_url + '/interpreter?data=' + URI.escape(query)
    end

    def self.get_overpass_instance_url
      return CartoCSSHelper::Configuration.get_overpass_instance_url
    end
  end
end
