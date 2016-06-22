require_relative 'util/generic_cached_downloader.rb'

module CartoCSSHelper
  class NotesDownloader
    def self.run_note_query(lat, lon, range, invalidate_cache: false)
      timeout = NotesDownloader.get_allowed_timeout_in_seconds
      downloader = GenericCachedDownloader.new(timeout: timeout, stop_on_timeout: false)

      url = NotesDownloader.format_query_into_url(lat, lon, range)
      cache_filename = CartoCSSHelper::Configuration.get_path_to_folder_for_notes_api_cache + url.delete("/") + ".cache"
      return downloader.get_specified_resource(url, cache_filename, invalidate_cache: invalidate_cache)
    end

    def self.cache_timestamp(lat, lon, range)
      downloader = GenericCachedDownloader.new

      url = NotesDownloader.format_query_into_url(lat, lon, range)
      cache_filename = CartoCSSHelper::Configuration.get_path_to_folder_for_notes_api_cache + url.delete("/") + ".cache"
      return downloader.get_cache_timestamp(cache_filename)
    end

    def self.get_allowed_timeout_in_seconds
      return 10 * 60
    end

    def self.format_query_into_url(lat, lon, range)
      # documentated at http://wiki.openstreetmap.org/wiki/API_v0.6#Map_Notes_API
      bbox = osm_api_bbox_string(lat, lon, range)
      base_url = "http://api.openstreetmap.org/api/0.6/notes"
      return "#{base_url}?bbox=#{bbox}?closed=0"
    end

    def self.osm_api_bbox_string(latitude, longitude, size)
      # bbox=left,bottom,right,top
      min_latitude = latitude - size / 2
      max_latitude = latitude + size / 2
      min_longitude = longitude - size / 2
      max_longitude = longitude + size / 2
      return "#{min_longitude},#{min_latitude},#{max_longitude},#{max_latitude}"
    end

    def self.get_overpass_instance_url
      return CartoCSSHelper::Configuration.get_overpass_instance_url
    end
  end
end
