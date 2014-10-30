# encoding: UTF-8
require 'fileutils'
def main
	style_filenames = Dir[get_style_path+"*.mss"]
	for style_filename in style_filenames
		puts style_filename
		style_file = open(style_filename)
		style = style_file.read()
		matched = style.scan(/\[feature = '(man_made|[^_]+)_([^']+)'\]/)
		tag = nil
		for element in matched
			for zlevel in 4..19
				if element[0] == 'shop' && element[1] == 'other'
					next
				end
				#puts "#{element[0]}=#{element[1]}"
				run_tests element[0], element[1], zlevel
			end
		end
	end
end

def get_data_filename
	return get_path_to_folder_for_temporary_files+'data.osm'
end

def get_style_path
	return ENV['HOME']+"/Desktop/OSM/tilemill/osm-carto/"
end

def get_path_to_folder_for_temporary_files
	return ENV['HOME']+"/Desktop/OSM/tilemill/cmp/tmp/"
end

def run_tests key, value, zlevel
	if !is_object_displaying_anything key, value, zlevel
		#puts key+"="+value+" - not displayed as node on z#{zlevel}"
		return
	end
	if !is_object_displaying_name key, value, "a", 0, zlevel
		puts key+"="+value+" - label is missing on z#{zlevel} nodes"
		return
	end
	names = ["ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ"]
	id = 0
	for name in names
		id += 1
		while !is_object_displaying_name key, value, name, id, zlevel
			puts key+"="+value+" - name is missing for name '#{name}' on z#{zlevel}"
			puts "press enter"
			gets
			File.delete(get_filename(key, value, name, id, zlevel))
			puts "calculating"
		end
		#puts key+"="+value+" - name is OK for name '#{name}'"
	end
end

def get_filename key, value, name, id, zlevel
	ascii_name = name.encode('ASCII', :invalid => :replace, :undef => :replace).gsub("?", "").gsub(" ", "")
	export_filename = get_path_to_folder_for_temporary_files+key+'_'+value+'_'+ascii_name+'_'+id.to_s+'_z'+zlevel.to_s+"_node"+'.png'
	return export_filename
end

def get_filename_for_nameless_object key, value, zlevel
	return get_path_to_folder_for_temporary_files+key+'_'+value+'_'+'nameless_z'+zlevel.to_s+"_node"+'.png'
end

def is_object_displaying_name key, value, name, id, zlevel
	tags = [
		[key, value],
		["name", name],
	]
	export_filename_nameless = get_filename_for_nameless_object(key, value, zlevel)
	export_filename = get_filename(key, value, name, id, zlevel)
	if !File.exists?(export_filename)
		turn_tags_into_image(tags, export_filename, zlevel)
        end

	tags = [
		[key, value],
	]

	if !File.exists?(export_filename_nameless)
		turn_tags_into_image(tags, export_filename_nameless, zlevel)
	end

	#Returns true if the contents of a file A and a file B are identical.
	return !FileUtils.compare_file(export_filename_nameless, export_filename)
end

def is_object_displaying_anything key, value, zlevel
	empty_filename = get_path_to_folder_for_temporary_files+"empty.png"
	if !File.exists?(empty_filename)
		turn_tags_into_image([], empty_filename, zlevel)
	end
	export_filename_nameless = get_filename_for_nameless_object(key, value, zlevel)
	if !File.exists?(export_filename_nameless)
		turn_tags_into_image([[key, value]], export_filename_nameless, zlevel)
	end
	return !FileUtils.compare_file(export_filename_nameless, empty_filename)
end

def turn_tags_into_image(tags, export_filename, zlevel)
	debug = false
	
	lat = 0
	lon = 20

	generate_data_file tags, lat, lon
	load_data_into_database debug
	generate_image tags, export_filename, zlevel, debug, lat, lon
	
	if !File.exists?(export_filename)
		raise "turn_tags_into_image failed"
	end
end

def generate_image tags, export_filename, zlevel, debug, lat, lon
	silence = "> /dev/null 2>&1"
	if debug
		silence = ""
	end
	size = 0.2
	#--bbox=[xmin,ymin,xmax,ymax] 
	bbox = "#{lon-size/2},#{lat-size/2},#{lon+size/2},#{lat+size/2}"
	params = "--format=png --width=200 --height=200 --static_zoom=#{zlevel} --bbox=\"#{bbox}\""
	command = "node /usr/share/tilemill/index.js export osm-carto #{export_filename} #{params} #{silence}"
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

main()