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
				puts "#{tag[0]}=#{tag[1]} - composite with #{last_composite[0]} - and maybe other tags"
			end
		else
			puts "#{tag[0]}=#{tag[1]} - primary"
			last_composite = nil
		end
	end
end

def is_rendered key, value
	for on_water in [false, true]
		for zlevel in [19]
			if rendered_on_zlevel [[key, value], ["area", "yes"]], "closed_way", zlevel, on_water
				return true
			end
			if rendered_on_zlevel [[key, value]], "closed_way", zlevel, on_water
				return true
			end
			if rendered_on_zlevel [[key, value]], "node", zlevel, on_water
				return true
			end
		end
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
	for on_water in [false, true]
		for zlevel in [19]
			result = how_rendered_on_zlevel_as_composite [[key, value], ["area", "yes"]], "closed_way", zlevel, true, on_water, suggested_composite
			if result != nil
				return result
			end
			result = how_rendered_on_zlevel_as_composite [[key, value]], "closed_way", zlevel, false, on_water, suggested_composite
			if result != nil
				return result
			end
			result = how_rendered_on_zlevel_as_composite [[key, value]], "node", zlevel, false, on_water, suggested_composite
			if result != nil
				return result
			end
		end
	end
	if suggested_composite != nil
		return how_rendered_as_composite key, value, nil
	end
	return nil
end

def rendered_on_zlevel tags, type, zlevel, on_water
	return is_output_different(tags, [], zlevel, type, on_water)
end

def how_rendered_on_zlevel_as_composite tags, type, zlevel, area, on_water, suggested_composite
	if suggested_composite != nil
		if is_rendered_with_this_composite tags, type, suggested_composite, zlevel, area, on_water
			return suggested_composite
		end
		return nil
	end
	composite_sets = [
	[["name", "a"]], #place=*
	[["highway", "secondary"]], #access, ref, bridge, tunnel...
	[["boundary", "administrative"]], #admin_level
	[["admin_level", "2"]], #boundary=administrative
	[["natural", "peak"]], #ele
	[["ref", "3"]], #aeroway=gate
	[["amenity", "place_of_worship"]], #religion
	[["amenity", "place_of_worship"], ["religion", "christian"]], #denomination
	[['waterway', 'river']], #bridge=aqueduct, tunnel=culvert
	[['barrier', 'hedge']], #area=yes
	]
	for composite in composite_sets
		if is_rendered_with_this_composite tags, type, composite, zlevel, area, on_water
			return composite
		end
	end
	return nil
end

def is_rendered_with_this_composite tags, type, composite, zlevel, area, on_water
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
		if is_output_different(tags_with_composite, used_composite, zlevel, type, on_water)
			return true
		end
	end
	return false
end
