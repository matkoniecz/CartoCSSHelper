# encoding: UTF-8
load 'config.rb'
load 'tag_hunter.rb'
require 'fileutils'

def is_output_different(tags_a, tags_b, zlevel, type_a, type_b, on_water)
	filename_a = get_image_from_tags(tags_a, zlevel, type_a, on_water)
	filename_b = get_image_from_tags(tags_b, zlevel, type_b, on_water)
	#Returns true if the contents of a file A and a file B are identical.
	return !FileUtils.compare_file(filename_a, filename_b)
end

def get_filename(tags, zlevel, type, on_water)
	water_part = ''
	if on_water
		water_part = '_water'
	end
	return get_path_to_folder_for_temporary_files+tags.sort.to_s+'_'+zlevel.to_s+water_part+'_'+type+'.png'
end

def flush_cashe(tags, zlevel, type, on_water, debug = false)
	File.delete(get_filename(tags, zlevel, type, on_water))
end

def get_image_from_tags(tags, zlevel, type, on_water, debug = false)
	lat = 0
	lon = 20
	if on_water
		lon = 0
	end
	export_filename = get_filename tags, zlevel, type, on_water
	if File.exists?(export_filename)
		return export_filename
	end
	turn_tags_into_image(tags, zlevel, type, on_water, lat, lon)
	if !File.exists?(export_filename)
		raise "turn_tags_into_image failed #{description}"
	end
	return export_filename
end

def turn_tags_into_image(tags, zlevel, type, on_water, lat, lon, debug = false)
	on_water_string = ''
	if on_water
		on_water_string = 'on_water'
	end
	description = "tags: #{tags.to_s}, zlevel: #{zlevel}, type: #{type} #{on_water_string}"
	puts description
	generate_data_file tags, lat, lon, type
	load_data_into_database debug
	generate_image tags, type, zlevel, lat, lon, on_water, debug
end

def get_data_filename
	return get_path_to_folder_for_temporary_files+'data.osm'
end

def get_size
	return 0.2
end

def generate_image(tags, type, zlevel, lat, lon, on_water, debug)
	silence = '> /dev/null 2>&1'
	if debug
		silence = ''
	end
	export_filename = get_filename tags, zlevel, type, on_water
	size = get_size
	#--bbox=[xmin,ymin,xmax,ymax] 
	bbox = "#{lon-size/2},#{lat-size/2},#{lon+size/2},#{lat+size/2}"
	params = "--format=png --width=200 --height=200 --static_zoom=#{zlevel} --bbox=\"#{bbox}\""
	command = "node /usr/share/tilemill/index.js export osm-carto '#{export_filename}' #{params} #{silence}"
	if debug
		puts command
	end
	system command
end

def add_node_to_data_file(tags, lat, lon, data_file, id) #TODO kill godawful ID
	data_file.write "\n"
	data_file.write "  <node id='#{id}' visible='true' lat='#{lat}' lon='#{lon}'>"
	tags.each { |tag|
		data_file.write "\n"
		data_file.write "    <tag k='#{tag[0]}' v='#{tag[1]}' />"
	}
	data_file.write '</node>'
end

def add_way_to_data_file(tags, nodes, data_file, id) #TODO kill godawful ID
	data_file.write "\n"
	data_file.write "  <way id='#{id}' visible='true'>"
	nodes.each { |node|
		data_file.write "\n"
		data_file.write "    <nd ref='#{node}' />"
	}
	tags.each { |tag|
		data_file.write "\n"
		data_file.write "    <tag k='#{tag[0]}' v='#{tag[1]}' />"
	}
	data_file.write "\n  </way>"
end

def generate_data_file(tags, lat, lon, type)
	if type == 'area'
		tags.push(['area', 'yes'])
		return raw_generate_data_file tags, lat, lon, 'closed way'
	end
	return raw_generate_data_file(tags, lat, lon, type)
end

def raw_generate_data_file(tags, lat, lon, type)
	data_file = open(get_data_filename, 'w')
	data_file.write "<?xml version='1.0' encoding='UTF-8'?>\n<osm version='0.6' generator='script'>"
	if type == 'node'
		add_node_to_data_file tags, lat, lon, data_file, 2387
	elsif type == 'way'
		add_node_to_data_file [], lat, lon-get_size/3, data_file, 1
		add_node_to_data_file [], lat, lon+get_size/3, data_file, 2
		add_way_to_data_file tags, [1, 2], data_file, 3
	elsif type == 'closed_way'
		add_node_to_data_file [], lat-get_size/3, lon-get_size/3, data_file, 1
		add_node_to_data_file [], lat-get_size/3, lon+get_size/3, data_file, 2
		add_node_to_data_file [], lat+get_size/3, lon+get_size/3, data_file, 3
		add_node_to_data_file [], lat+get_size/3, lon-get_size/3, data_file, 4
		add_way_to_data_file tags, [1, 2, 3, 4, 1], data_file, 5
	else
		raise
	end
	data_file.write "\n</osm>"
	data_file.close
end

def load_data_into_database(debug)
	silence = '> /dev/null 2>&1'
	if debug
		silence = ''
	end

	command = "osm2pgsql --create --slim --cache 10 --number-processes 1 --hstore --style #{get_style_path}openstreetmap-carto.style --multi-geometry #{get_data_filename} #{silence}"
	if debug
		puts command
	end
	system command
end
