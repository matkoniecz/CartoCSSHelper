load 'config.rb'

def get_filename tags, zlevel, type
	return get_path_to_folder_for_temporary_files+tags.to_s+"_"+zlevel.to_s+"_"+type+".png"
end

def turn_tags_into_image(tags, zlevel, type)
	debug = false
	
	lat = 0
	lon = 20
	export_filename = get_filename tags, zlevel, type
	if File.exists?(export_filename)
		return
	end
	generate_data_file tags, lat, lon
	load_data_into_database debug
	generate_image tags, type, zlevel, lat, lon, debug
	
	if !File.exists?(export_filename)
		raise "turn_tags_into_image failed"
	end
end

def get_data_filename
	return get_path_to_folder_for_temporary_files+'data.osm'
end

def generate_image tags, type, zlevel, lat, lon, debug
	silence = "> /dev/null 2>&1"
	if debug
		silence = ""
	end
	export_filename = get_filename tags, zlevel, type
	size = 0.2
	#--bbox=[xmin,ymin,xmax,ymax] 
	bbox = "#{lon-size/2},#{lat-size/2},#{lon+size/2},#{lat+size/2}"
	params = "--format=png --width=200 --height=200 --static_zoom=#{zlevel} --bbox=\"#{bbox}\""
	command = "node /usr/share/tilemill/index.js export osm-carto '#{export_filename}' #{params} #{silence}"
	if debug
		puts command
	end
	system command
end

def generate_data_file tags, lat, lon
	data_file = open(get_data_filename, 'w')
	data_file.write "<?xml version='1.0' encoding='UTF-8'?>\n<osm version='0.6' generator='script'>"

	data_file.write "  <node id='-2387' visible='true' lat='#{lat}' lon='#{lon}'>"
	for tag in tags
		data_file.write "\n"
		data_file.write "    <tag k='#{tag[0]}' v='#{tag[1]}' />"
	end
	data_file.write "</node>\n</osm>"
	data_file.close
end

def load_data_into_database debug
	silence = "> /dev/null 2>&1"
	if debug
		silence = ""
	end

	command = "osm2pgsql --create --slim --cache 10 --number-processes 1 --hstore --style #{get_style_path}openstreetmap-carto.style --multi-geometry #{get_data_filename} #{silence}"
	if debug
		puts command
	end
	system command
end
