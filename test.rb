# encoding: UTF-8

load 'validator.rb'

def main
	list_render_state
	run_tests
end

def list_render_state
	tags = get_tags
	last_composite = nil
	for tag in tags
		key = tag[0]
		value = tag[1]
		if !is_rendered key, value
			if !is_rendered_as_composite key, value, last_composite
				puts "#{tag[0]}=#{tag[1]} - not displayed"
				last_composite = nil
			else
				last_composite = how_rendered_as_composite key, value, last_composite
				puts "#{tag[0]}=#{tag[1]} - composite with #{last_composite} - and maybe other tags"
			end
		else
			puts "#{tag[0]}=#{tag[1]} - primary"
			last_composite = nil
		end
	end
end

def is_rendered key, value
	if rendered_on_zlevel [[key, value], ["area", "yes"]], "closed_way", 19
		return true
	end
	if rendered_on_zlevel [[key, value], ["area", "yes"]], "closed_way", 5
		return true
	end
	if rendered_on_zlevel [[key, value]], "way", 19
		return true
	end
	if rendered_on_zlevel [[key, value]], "way", 5
		return true
	end
	if rendered_on_zlevel [[key, value]], "node", 19
		return true
	end
	if rendered_on_zlevel [[key, value]], "node", 5
		return true
	end
	return false
end

def is_rendered_as_composite key, value, suggested_composite
	reason = how_rendered_as_composite key, value, suggested_composite
	if reason == nil
		return false
	end
	return true
end

def how_rendered_as_composite key, value, suggested_composite
	result = how_rendered_on_zlevel_as_composite [[key, value], ["area", "yes"]], "closed_way", 19, true, suggested_composite
	if result != nil
		return result
	end
	result = how_rendered_on_zlevel_as_composite [[key, value], ["area", "yes"]], "closed_way", 5, true, suggested_composite
	if result != nil
		return result
	end
	result = how_rendered_on_zlevel_as_composite [[key, value]], "way", 19, false, suggested_composite
	if result != nil
		return result
	end
	result = how_rendered_on_zlevel_as_composite [[key, value]], "way", 5, false, suggested_composite
	if result != nil
		return result
	end
	result = how_rendered_on_zlevel_as_composite [[key, value]], "node", 19, false, suggested_composite
	if result != nil
		return result
	end
	result = how_rendered_on_zlevel_as_composite [[key, value]], "node", 5, false, suggested_composite
	if result != nil
		return result
	end
	if suggested_composite != nil
		return how_rendered_as_composite key, value, nil
	end
	return nil
end

def rendered_on_zlevel tags, type, zlevel
	return is_output_different(tags, [], zlevel, type)
end

def how_rendered_on_zlevel_as_composite tags, type, zlevel, area, suggested_composite
	if suggested_composite != nil
		if is_rendered_with_this_composite tags, type, suggested_composite, zlevel, area
			return suggested_composite
		end
		return nil
	end
	composite_sets = [
	[["name", "a"]],
	[["highway", "secondary"]],
	[["boundary", "administrative"]],
	[["admin_level", "2"]],
	[["natural", "peak"]],
	[["ref", "3"]],
	[["ele", "4"]],
	[["amenity", "place_of_worship"]],
	[["amenity", "place_of_worship"], ["religion", "christian"]],
	[['waterway', 'river']]
	]
	for composite in composite_sets
		if is_rendered_with_this_composite tags, type, composite, zlevel, area
			return composite
		end
	end
	return nil
end

def is_rendered_with_this_composite tags, type, composite, zlevel, area
	#puts "<<<\n#{tags}\n#{composite}<<<\n\n"
	tags_with_composite = Marshal.load(Marshal.dump(tags))
	used_composite = Marshal.load(Marshal.dump(composite))
	for added in composite
		tags_with_composite.push(added)
	end
	if area
		used_composite.push(["area", "yes"])
	end
	if is_output_different(tags_with_composite, [], zlevel, type)
		if is_output_different(tags_with_composite, used_composite, zlevel, type)
			return true
		end
	end
	return false
end



main()
