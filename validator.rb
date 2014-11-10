# encoding: UTF-8
load 'tag_hunter.rb'
load 'image_generator.rb'
load 'config.rb'

def run_tests
	run_global_check_problems_with_closed_line
	run_global_check_dy
end

def run_global_check_problems_with_closed_line
	tags = get_tags
	count = 0
	for element in tags
		for zlevel in get_max_z..get_max_z
			check_problems_with_closed_line element[0], element[1], zlevel
		end
		count += 1
		puts "#{count} of #{tags.length}"
	end
end

def run_global_check_dy
	tags = get_tags
	count = 0
	for element in tags
		for zlevel in 4..get_max_z
			check_dy element[0], element[1], zlevel
		end
		count += 1
		puts "#{count} of #{tags.length}"
	end
end

def check_problems_with_closed_line key, value, zlevel
	on_water = false
	tag = [[key, value]]
	if is_output_different(tag, [], zlevel, "way", "closed_way", on_water)
		if !is_output_different(tag, [], zlevel, "closed_way", "closed_way", on_water)
			puts key+"="+value+" - failed display of closed way"
		end
	end
end

def check_dy key, value, zlevel
	if !is_object_displaying_anything key, value, zlevel
		#puts key+"="+value+" - not displayed as node on z#{zlevel}"
		return
	end
	if !is_object_displaying_name key, value, "a", zlevel
		#puts key+"="+value+" - label is missing on z#{zlevel} nodes"
		return
	end
	test_name = "ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ"
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
	return is_output_different(nameless, name, zlevel, "node", "node", on_water)
end

def is_object_displaying_anything key, value, zlevel
	on_water = false
	tag = [[key, value], ["name", "a"]]
	return is_output_different(tag, [], zlevel, "node", "node", on_water)
end
