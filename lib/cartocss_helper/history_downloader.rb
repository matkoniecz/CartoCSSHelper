# frozen_string_literal: true

require_relative 'util/generic_cached_downloader.rb'

module CartoCSSHelper
  class HistoryDownloader
    def self.cache_filename(type, id)
      url = HistoryDownloader.format_query_into_url(type, id)
      return CartoCSSHelper::Configuration.get_path_to_folder_for_history_api_cache + url.delete("/") + ".cache"
    end

    def self.run_history_query(type, id, invalidate_cache: false)
      timeout = HistoryDownloader.get_allowed_timeout_in_seconds
      downloader = GenericCachedDownloader.new(timeout: timeout, stop_on_timeout: false)
      file = cache_filename(type, id)
      url = HistoryDownloader.format_query_into_url(type, id)
      return downloader.get_specified_resource(url, file, invalidate_cache: invalidate_cache)
    end

    def self.cache_timestamp(type, id)
      downloader = GenericCachedDownloader.new
      file = cache_filename(type, id)
      return downloader.get_cache_timestamp(file)
    end

    def self.get_allowed_timeout_in_seconds
      return 10 * 60
    end

    def self.format_query_into_url(type, id)
      # documentated at https://wiki.openstreetmap.org/wiki/API_v0.6
      return "http://api.openstreetmap.org/api/0.6/#{type}/#{id}/history"
    end
  end
end
