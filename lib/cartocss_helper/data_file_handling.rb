# encoding: UTF-8
require_relative 'configuration'
require_relative 'util/systemhelper.rb'

module CartoCSSHelper
  class DataFileLoader
    @@loaded_filename = nil
    def self.get_filename_of_recently_loaded_file
      if @@loaded_filename == Configuration.get_data_filename
        return nil
      end
      return @@loaded_filename
    end

    def self.load_data_into_database(data_filename, debug = false)
      if get_filename_of_recently_loaded_file == data_filename
        puts "\tavoided reloading the same file! <#{data_filename}>"
        return
      end
      start_time = Time.now
      puts "\tloading data into database <#{data_filename}>"
      @@loaded_filename = nil
      silence = to_devnull_without_debug(debug)

      command = "osm2pgsql --create --slim --cache 10 --number-processes 1 --hstore --style #{Configuration.get_style_file_location} --multi-geometry '#{data_filename}' #{silence}"
      if debug
        puts command
      end
      unless system(command)
        puts 'loading data into database failed'
        if !debug
          puts 'retry with enabled debug'
          load_data_into_database(data_filename, true)
        else
          raise 'osm2pgsql failed'
        end
      end
      @@loaded_filename = data_filename
      time_in_seconds = Time.now - start_time
      puts "\tloading lasted #{time_in_seconds.to_i}s"
    end
  end

  class DataFileGenerator
    def initialize(tags, type, lat, lon, size)
      @lat = lat
      @lon = lon
      @tags = tags
      @type = type
      @size = size
    end

    def open_file
      @data_file = open(Configuration.get_data_filename, 'w')
    end

    def close_file
      @data_file.close
    end

    def prepare_file
      open_file
      generate_prefix
    end

    def finish_file
      generate_sufix
      close_file
    end

    def generate
      prepare_file
      if @type == 'node'
        generate_node_topology(@lat, @lon, @tags)
      elsif @type == 'way'
        generate_way_topology(@lat, @lon, @tags)
      elsif @type == 'closed_way'
        generate_closed_way_topology(@lat, @lon, @tags)
      else
        raise 'this type of element does not exists'
      end
      finish_file
    end

    def generate_node_topology(lat, lon, tags)
      add_node lat, lon, tags, 2387
    end

    def generate_way_topology(lat, lon, tags)
      add_node lat, lon - @size / 3, [], 1
      add_node lat, lon + @size / 3, [], 2
      add_way tags, [1, 2], 3
    end

    def generate_closed_way_topology(lat, lon, tags)
      delta = @size / 3
      add_node lat - delta, lon - delta, [], 1
      add_node lat - delta, lon + delta, [], 2
      add_node lat + delta, lon + delta, [], 3
      add_node lat + delta, lon - delta, [], 4
      add_way tags, [1, 2, 3, 4, 1], 5
    end

    def generate_prefix
      @data_file.write "<?xml version='1.0' encoding='UTF-8'?>\n<osm version='0.6' generator='script'>"
    end

    def generate_sufix
      @data_file.write "\n</osm>"
    end

    def add_node(lat, lon, tags, id)
      @data_file.write "\n"
      @data_file.write "  <node id='#{id}' visible='true' lat='#{lat}' lon='#{lon}'>"
      add_tags(tags)
      @data_file.write '</node>'
    end

    def add_way(tags, nodes, id)
      @data_file.write "\n"
      @data_file.write "  <way id='#{id}' visible='true'>"
      nodes.each { |node|
        @data_file.write "\n"
        @data_file.write "    <nd ref='#{node}' />"
      }
      add_tags(tags)
      @data_file.write "\n  </way>"
    end

    def add_tags(tags)
      tags.each { |tag|
        @data_file.write "\n"
        @data_file.write "    <tag k='#{tag[0]}' v='#{tag[1]}' />"
      }
    end
  end
end
