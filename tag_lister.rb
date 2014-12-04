load 'config.rb'

def list_render_state
	tags = get_tags
	last_composite = nil
	tags.each { |tag|
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
	}
end

def is_rendered(key, value)
	[false, true].each { |on_water|
		[get_max_z].each { |zlevel|
			if rendered_on_zlevel [[key, value], ['area', 'yes']], 'closed_way', zlevel, on_water
				return true
			end
			if rendered_on_zlevel [[key, value]], 'closed_way', zlevel, on_water
				return true
			end
			if rendered_on_zlevel [[key, value]], 'node', zlevel, on_water
				return true
			end
		}
	}
	return false
end

def is_rendered_as_composite(key, value, suggested_composite)
	reason = how_rendered_as_composite key, value, suggested_composite
	if reason == nil
		return false
	end
	return true
end

def how_rendered_as_composite(key, value, suggested_composite)
	[false, true].each { |on_water|
		[19].each { |zlevel|
			result = how_rendered_on_zlevel_as_composite [[key, value], ['area', 'yes']], 'closed_way', zlevel, true, on_water, suggested_composite
			if result != nil
				return result
			end
			result = how_rendered_on_zlevel_as_composite [[key, value]], 'closed_way', zlevel, false, on_water, suggested_composite
			if result != nil
				return result
			end
			result = how_rendered_on_zlevel_as_composite [[key, value]], 'node', zlevel, false, on_water, suggested_composite
			if result != nil
				return result
			end
		}
	}
	if suggested_composite != nil
		return how_rendered_as_composite key, value, nil
	end
	return nil
end

def rendered_on_zlevel(tags, type, zlevel, on_water)
	return is_output_different(tags, [], zlevel, type, type, on_water)
end

def how_rendered_on_zlevel_as_composite(tags, type, zlevel, area, on_water, suggested_composite)
	if suggested_composite != nil
		if is_rendered_with_this_composite tags, type, suggested_composite, zlevel, area, on_water
			return suggested_composite
		end
		return nil
	end
	composite_sets = [
			[['name', 'a']], #place=*
			[['highway', 'secondary']], #access, ref, bridge, tunnel...
			[['boundary', 'administrative']], #admin_level
			[['admin_level', '2']], #boundary=administrative
			[['natural', 'peak']], #ele
			[['ref', '3']], #aeroway=gate
			[['amenity', 'place_of_worship']], #religion
			[['amenity', 'place_of_worship'], ['religion', 'christian']], #denomination
			[['waterway', 'river']], #bridge=aqueduct, tunnel=culvert
			[['barrier', 'hedge']], #area=yes
	]
	composite_sets.each { |composite|
		if is_rendered_with_this_composite tags, type, composite, zlevel, area, on_water
			return composite
		end
	}
	return nil
end

def is_rendered_with_this_composite(tags, type, composite, zlevel, area, on_water)
	#puts "<<<\n#{tags}\n#{composite}<<<\n\n"
	# noinspection RubyResolve
	# see https://youtrack.jetbrains.com/issue/RUBY-16061
	tags_with_composite = Marshal.load(Marshal.dump(tags))
	# noinspection RubyResolve
	# see https://youtrack.jetbrains.com/issue/RUBY-16061
	used_composite = Marshal.load(Marshal.dump(composite))
	composite.each { |added|
		tags_with_composite.push(added)
	}
	if area
		used_composite.push(['area', 'yes'])
	end
	if is_output_different(tags_with_composite, [], zlevel, type, type, on_water)
		if is_output_different(tags_with_composite, used_composite, zlevel, type, type, on_water)
			return true
		end
	end
	return false
end

