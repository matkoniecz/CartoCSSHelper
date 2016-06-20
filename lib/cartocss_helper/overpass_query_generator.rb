# encoding: UTF-8
require 'digest/sha1'
require 'sys/filesystem'
require_relative 'overpass_downloader.rb'
require_relative 'util/systemhelper.rb'

module CartoCSSHelper
  class OverpassQueryGenerator
    class NoLocationFound < StandardError
    end
    # TODO: - split into cache handling and Overpass handling
    def self.get_query_to_find_data_pair(bb, tags_a, tags_b, type_a, type_b, distance_in_meters: 20)
      filter_a = OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter(tags_a)
      filter_b = OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter(tags_b)

      query = "[timeout:#{OverpassDownloader.get_allowed_timeout_in_seconds}][out:csv(::lat,::lon;false)];
      #{type_a}(#{bb})#{filter_a};
      node(around:#{distance_in_meters})->.anodes;
      #{type_b}(#{bb})#{filter_b};
      node(around:#{distance_in_meters}).anodes;
      out;"

      return query
    end

    def self.overpass_bbox_string(latitude, longitude, size)
      min_latitude = latitude - size / 2
      max_latitude = latitude + size / 2
      min_longitude = longitude - size / 2
      max_longitude = longitude + size / 2
      return "#{min_latitude},#{min_longitude},#{max_latitude},#{max_longitude}"
    end

    def self.find_data_pair(tags_a, tags_b, latitude, longitude, type_a, type_b, bb_size: 0.1, distance_in_meters: 20)
      return nil, nil if bb_size > 0.5
      bb = overpass_bbox_string(latitude, longitude, bb_size.to_f)
      query = OverpassQueryGenerator.get_query_to_find_data_pair(bb, tags_a, tags_b, type_a, type_b, distance_in_meters: distance_in_meters)
      description = "find #{VisualDiff.dict_to_pretty_tag_list(tags_a)} nearby #{VisualDiff.dict_to_pretty_tag_list(tags_b)} - bb size: #{bb_size}"
      list = OverpassQueryGenerator.get_overpass_query_results(query, description)
      if list.length != 0
        return OverpassQueryGenerator.list_returned_by_overpass_to_a_single_location(list)
      end
      return OverpassQueryGenerator.find_data_pair(tags_a, tags_b, latitude, longitude, type_a, type_b, bb_size: bb_size * 2, distance_in_meters: distance_in_meters)
    end

    def self.get_file_with_downloaded_osm_data_for_location(latitude, longitude, size)
      query = get_query_to_download_data_around_location(latitude, longitude, size)
      description = "download data for #{latitude} #{longitude} (#{size})"
      get_overpass_query_results(query, description)

      filename = get_query_cache_filename(query)
      return filename
    end

    def self.download_osm_data_for_location(latitude, longitude, size, accept_cache = true)
      filename = CartoCSSHelper::Configuration.get_path_to_folder_for_cache + "#{latitude} #{longitude} #{size}.osm"
      if File.exist?(filename)
        return filename if accept_cache
        SystemHelper.delete_file(filename, 'query refusing to accept cache was used')
      end
      query = get_query_to_download_data_around_location(latitude, longitude, size)
      text = get_overpass_query_results(query, "download data for #{latitude} #{longitude} (#{size})")
      File.new(filename, 'w') do |file|
        file.write text
      end
      return filename
    end

    def self.get_query_to_download_data_around_location(latitude, longitude, size)
      bb = overpass_bbox_string(latitude, longitude, size)
      query = "[timeout:#{OverpassDownloader.get_allowed_timeout_in_seconds}];"
      query += "\n"
      query += "(node(#{bb});<;);"
      query += "\n"
      query += 'out;'
      query += "\n"
      query += '/*'
      query += "\nbbox size: #{size}"
      query += "\nhttp://www.openstreetmap.org/#map=17/#{latitude}/#{longitude}"
      query += "\n"
      query += '*/'
      query += "\n"
      return query
    end

    def self.get_elements_near_given_location(tags, type, latitude, longitude, range_in_meters)
      description = "find #{tags} #{type} within #{range_in_meters / 1000}km from #{latitude}, #{longitude}"
      query = OverpassQueryGenerator.get_query_to_get_location(tags, type, latitude, longitude, range_in_meters)
      list = OverpassQueryGenerator.get_overpass_query_results(query, description)
      return list_returned_by_overpass_to_array(list)
    end

    def self.get_elements_across_world(tags, type)
      description = "find #{tags} #{type} across the world"
      query = OverpassQueryGenerator.get_query_to_get_location(tags, type, 0, 0, :infinity)
      list = OverpassQueryGenerator.get_overpass_query_results(query, description)
      return list_returned_by_overpass_to_array(list)
    end

    def self.locate_element_with_given_tags_and_type(tags, type, latitude, longitude, max_range_in_km_for_radius = 1600)
      # special support for following tag values:  :any_value
      range = 10 * 1000
      while range <= max_range_in_km_for_radius * 1000
        list = OverpassQueryGenerator.get_elements_near_given_location(tags, type, latitude, longitude, range)
        return list[0] if list.length != 0
        range += [2 * range, 200000].min
      end
      list = get_elements_across_world(tags, type)
      if list.length != 0
        return list[0]
      else
        raise NoLocationFound, "failed to find #{tags} #{type} across the world"
      end
    end

    def self.list_returned_by_overpass_to_a_single_location(list)
      list = list_returned_by_overpass_to_array(list)
      return list[0]
    end

    def self.list_returned_by_overpass_to_array(list)
      list = list.split("\n")
      new_list = list.map do |x|
        x = x.split("\t")
        x[0] = x[0].to_f
        x[1] = x[1].to_f
        x
      end
      return new_list
    end

    def self.get_query_to_get_location(tags, type, latitude, longitude, range)
      return get_query_to_get_location_set_format(tags, type, latitude, longitude, range, "[out:csv(::lat,::lon;false)]")
    end

    def self.get_query_to_get_location_set_format(tags, type, latitude, longitude, range, format)
      # special support for following tag values:  :any_value
      locator = "[timeout:#{OverpassDownloader.get_allowed_timeout_in_seconds}]#{format};"
      locator += "\n"
      type = 'way' if type == 'closed_way'
      locator += OverpassQueryGenerator.get_query_element_to_get_location(tags, latitude, longitude, type, range)
      locator += 'out center;'
      locator += "\n"
      locator += '/*'
      range_string = if range == :infinity
                       'infinity'
                     else
                       "#{range / 1000}km"
                     end
      locator += "\nrange: #{range_string}"
      locator += "\nhttp://www.openstreetmap.org/#map=17/#{latitude}/#{longitude}"
      locator += "\n"
      locator += '*/'
      locator += "\n"
      return locator
    end

    def self.turn_list_of_tags_in_overpass_filter(tags)
      element = ''
      tags.each do |tag|
        element += if tag[1] == :any_value
                     "\t['#{tag[0]}']"
                   else
                     "\t['#{tag[0]}'='#{tag[1]}']"
                   end
        element += "\n"
      end
      return element
    end

    def self.get_query_element_to_get_location(tags, latitude, longitude, type, range)
      # special support for following tag values:  :any_value
      # TODO - escape value with quotation signs in them
      element = "(#{type}"
      element += OverpassQueryGenerator.turn_list_of_tags_in_overpass_filter(tags)
      element += "\n"
      if range != :infinity
        element += "\t(around:#{range},#{latitude},#{longitude});"
        element += "\n"
      end
      element += ');'
      element += "\n"
      return element
    end

    def self.get_query_cache_refused_response_filename(query)
      return get_query_cache_filename(query) + '_response_refused'
    end

    def self.mark_query_as_refused(query)
      file = File.new(get_query_cache_refused_response_filename(query), 'w')
      file.write ''
      file.close
    end

    def self.get_timestamp_of_file(timestamp_filename)
      return nil unless File.exist?(timestamp_filename)
      f = File.new(timestamp_filename)
      timestamp = f.mtime.to_i
      f.close
      return timestamp
    end

    def self.get_query_cache_filename(query)
      hash = Digest::SHA1.hexdigest query
      query_cache_filename = CartoCSSHelper::Configuration.get_path_to_folder_for_overpass_cache + hash + '_query.cache'
      return query_cache_filename
    end

    def self.get_overpass_query_results(query, description, debug = false)
      if File.exist?(get_query_cache_refused_response_filename(query))
        raise OverpassDownloader::OverpassRefusedResponse
      end

      check_for_free_space

      if debug
        puts query
        puts
      end

      cache_filename = get_query_cache_filename(query)
      description = 'Running Overpass query (connection initiated on ' + Time.now.to_s + ') ' + description
      begin
        return OverpassDownloader.run_overpass_query query, description, cache_filename
      rescue OverpassDownloader::OverpassRefusedResponse
        mark_query_as_refused(query)
        raise OverpassDownloader::OverpassRefusedResponse
      end
    end

    def self.check_for_free_space # TODO: it really does not belong here... - do system helpera? aż do końca klasy
      if SystemHelper.not_enough_free_space
        attempt_cleanup
        if SystemHelper.not_enough_free_space
          raise 'not enough free space on disk with cache folder'
        end
      end
    end

    def self.attempt_cleanup
      delete_large_overpass_caches 500 if SystemHelper.not_enough_free_space
      delete_large_overpass_caches 100 if SystemHelper.not_enough_free_space
      delete_large_overpass_caches 50 if SystemHelper.not_enough_free_space
    end

    def self.delete_large_overpass_caches(threshold_in_MB)
      # TODO: - find library that deals with caches like this, bug here may be unfunny
      Dir.glob(CartoCSSHelper::Configuration.get_path_to_folder_for_overpass_cache + '*') do |file|
        if File.size(file) > (1024 * 1024 * threshold_in_MB)
          SystemHelper.delete_file(file, "removing everpass cache entries larger than #{threshold_in_MB} MB to make free space on the disk")
        end
      end
    end
  end
end
