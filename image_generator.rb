# encoding: UTF-8
load 'configuration.rb'
load 'heuristic.rb'
require 'fileutils'
include Configuration
include Heuristic

class Scene
	attr_reader :tags, :zlevel, :on_water, :type
	def initialize(tags, zlevel, on_water, type)
		raise 'tags not in hash' unless tags.respond_to?(:has_key?)
		@tags = tags
		@zlevel = zlevel
		@on_water = on_water
		@type = type
		if type == 'area'
			@tags['area'] = 'yes'
			@type = 'closed_way'
		end
	end

	def is_output_different(another_scene)
		if @on_water != another_scene.on_water
			raise 'on_water mismatch'
		end
		#Returns true if the contents of a file A and a file B are identical.
		return !FileUtils.compare_file(self.get_image, another_scene.get_image)
	end

	def flush_cache
		File.delete(self.get_filename)
	end

	def get_image(debug=false, silent=false)
		lat = 0
		lon = 20
		on_water_string = ''
		if @on_water
			lon = 0
			on_water_string = 'on_water'
		end
		export_filename = self.get_filename
		if File.exists?(export_filename)
			return export_filename
		end
		description = "tags: #{@tags.to_s}, zlevel: #{@zlevel}, type: #{@type} #{on_water_string}"
		if !silent
			puts "generating: #{description}"
		end
		generate_map(lat, lon,  debug)
		if !File.exists?(export_filename)
			description = "get_image failed - #{description}. File <\n#{export_filename}\n> was expected."
			if debug
				raise description
			else
				puts description
				return get_image(true, false)
			end
		end
		return export_filename
	end

	protected

	def get_filename
		water_part = ''
		if @on_water
			water_part = '_water'
		end
		return Configuration.get_path_to_folder_for_temporary_files+@tags.to_a.sort.to_s+'_'+@zlevel.to_s+water_part+'_'+@type+'.png' #TODO - tags?
	end

	def generate_map(lat, lon, debug)
		data_file_maker = DataFileGenerator.new(tags, @type, lat, lon, get_size)
		data_file_maker.generate
		load_data_into_database debug
		generate_image lat, lon, debug
	end

	def get_size
		return 0.2
	end

	def generate_image(lat, lon, debug)
		silence = '> /dev/null 2>&1'
		if debug
			silence = ''
		end
		export_filename = self.get_filename
		size = self.get_size
		#--bbox=[xmin,ymin,xmax,ymax]
		bbox = "#{lon-size/2},#{lat-size/2},#{lon+size/2},#{lat+size/2}"
		params = "--format=png --width=200 --height=200 --static_zoom=#{@zlevel} --bbox=\"#{bbox}\""
		command = "node /usr/share/tilemill/index.js export osm-carto '#{export_filename}' #{params} #{silence}"
		#TODO - osm-carto is hardcoded
		if debug
			puts command
		end
		system command
	end

	def load_data_into_database(debug)
		silence = '> /dev/null 2>&1'
		if debug
			silence = ''
		end

		#TODO - openstreetmap-carto.style is hardcoded
		command = "osm2pgsql --create --slim --cache 10 --number-processes 1 --hstore --style #{Configuration.get_style_path}openstreetmap-carto.style --multi-geometry #{Configuration.get_data_filename} #{silence}"
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
