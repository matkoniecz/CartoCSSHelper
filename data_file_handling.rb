# encoding: UTF-8
require_relative 'configuration'

module CartoCSSHelper
  class DataFileLoader
    def self.load_data_into_database(data_filename, debug=false)
      silence = '> /dev/null 2>&1'
      if debug
        silence = ''
      end

      #TODO - openstreetmap-carto.style is hardcoded
      command = "osm2pgsql --create --slim --cache 10 --number-processes 1 --hstore --style #{Configuration.get_style_path}openstreetmap-carto.style --multi-geometry '#{data_filename}' #{silence}"
      if debug
        puts command
      end
      system command
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

    def generate
      @data_file = open(Configuration.get_data_filename, 'w')
      generate_prefix
      if @type == 'node'
        generate_node_topology(@lat, @lon, @tags)
      elsif @type == 'way'
        generate_way_topology(@lat, @lon, @tags)
      elsif @type == 'closed_way'
        generate_closed_way_topology(@lat, @lon, @tags)
      else
        raise
      end
      generate_sufix
      @data_file.close
    end

    def generate_node_topology(lat, lon, tags)
      add_node lat, lon, tags, 2387
    end

    def generate_way_topology(lat, lon, tags)
      add_node lat, lon-@size/3, [], 1
      add_node lat, lon+@size/3, [], 2
      add_way tags, [1, 2], 3
    end

    def generate_closed_way_topology(lat, lon, tags)
      delta = @size/3
      add_node lat-delta, lon-delta, [], 1
      add_node lat-delta, lon+delta, [], 2
      add_node lat+delta, lon+delta, [], 3
      add_node lat+delta, lon-delta, [], 4
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