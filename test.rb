# encoding: UTF-8
require 'fileutils'
load 'image_generator.rb'
load 'config.rb'
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



def run_tests key, value, zlevel
	if !is_object_displaying_anything key, value, zlevel
		#puts key+"="+value+" - not displayed as node on z#{zlevel}"
		return
	end
	if !is_object_displaying_name key, value, "a", zlevel
		#puts key+"="+value+" - label is missing on z#{zlevel} nodes"
		return
	end
	test_name = "ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ"
	while !is_object_displaying_name key, value, test_name, zlevel
		puts key+"="+value+" - name is missing for name '#{test_name}' on z#{zlevel}"
		puts "press enter"
		gets
		File.delete(get_filename [[key, value], ["name", name]], zlevel, "node")
		puts "calculating"
	end
	#puts key+"="+value+" - name is OK for name '#{name}'"
end

def is_object_displaying_name key, value, name, zlevel
	nameless = [[key, value]]
	name = [[key, value], ["name", name]]
	return is_output_different(nameless, name, zlevel, "node")
end

def is_object_displaying_anything key, value, zlevel
	tag = [[key, value]]
	return is_output_different(tag, [], zlevel, "node")
end

def is_output_different tags_a, tags_b, zlevel, type
	turn_tags_into_image(tags_a, zlevel, type)
	turn_tags_into_image(tags_b, zlevel, type)
	filename_a = get_filename tags_a, zlevel, type	
	filename_b = get_filename tags_b, zlevel, type	
	#Returns true if the contents of a file A and a file B are identical.
	return !FileUtils.compare_file(filename_a, filename_b)
end

main()