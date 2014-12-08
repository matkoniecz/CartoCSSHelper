load 'config.rb'
load 'image_generator.rb'
include Config

module Info
	def list_render_state
		tags = get_tags
		last_composite = nil
		tags.each { |tag|
			key = tag[0]
			value = tag[1]
			if is_rendered key, value
				puts "#{tag[0]}=#{tag[1]} - primary"
				last_composite = nil
			else
				if is_rendered_as_composite key, value, last_composite
					last_composite = how_rendered_as_composite key, value, last_composite
					puts "#{tag[0]}=#{tag[1]} - composite with #{last_composite} - and maybe other tags"
				else
					puts "#{tag[0]}=#{tag[1]} - not displayed"
					last_composite = nil
				end
			end
		}
	end

	def is_rendered(key, value)
		[false, true].each { |on_water|
			[Config.get_max_z].each { |zlevel|
				if rendered_on_zlevel({key => value, 'area' => 'yes'}, 'closed_way', zlevel, on_water)
					return true
				end
				if rendered_on_zlevel({key => value}, 'closed_way', zlevel, on_water)
					return true
				end
				if rendered_on_zlevel({key => value}, 'node', zlevel, on_water)
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
			[Config.get_max_z].each { |zlevel|
				result = how_rendered_on_zlevel_as_composite({key => value}, 'closed_way', zlevel, on_water, suggested_composite)
				if result != nil
					return result
				end
				result = how_rendered_on_zlevel_as_composite({key => value}, 'way', zlevel, on_water, suggested_composite)
				if result != nil
					return result
				end
				result = how_rendered_on_zlevel_as_composite({key => value}, 'node', zlevel, on_water, suggested_composite)
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
		empty = Scene.new({}, zlevel, on_water, type)
		tested = Scene.new(tags, zlevel, on_water, type)
		return tested.is_output_different(empty)
	end

	def how_rendered_on_zlevel_as_composite(tags, type, zlevel, on_water, suggested_composite)
		if suggested_composite != nil
			if is_rendered_with_this_composite tags, type, suggested_composite, zlevel, on_water
				return suggested_composite
			end
			return nil
		end
		composite_sets = [
				{'name' => 'a'}, #place=*
				{'highway' => 'secondary'}, #access, ref, bridge, tunnel...
				{'boundary' => 'administrative'}, #admin_level
				{'admin_level' => '2'}, #boundary=administrative
				{'natural' => 'peak'}, #ele
				{'ref' => '3'}, #aeroway=gate
				{'amenity' => 'place_of_worship'}, #religion
				{'amenity' => 'place_of_worship', 'religion' => 'christian'}, #denomination
				{'waterway' => 'river'}, #bridge=aqueduct, tunnel=culvert
				#{'barrier' => 'hedge'}, #area=yes
		]
		composite_sets.each { |composite|
			if is_rendered_with_this_composite tags, type, composite, zlevel, on_water
				return composite
			end
		}
		return nil
	end

	def is_rendered_with_this_composite(tags, type, composite, zlevel, on_water)
		#puts "<<<\n#{tags}\n#{composite}<<<\n\n"
		# noinspection RubyResolve
		# see https://youtrack.jetbrains.com/issue/RUBY-16061
		tags_with_composite = Marshal.load(Marshal.dump(tags))
		# noinspection RubyResolve
		# see https://youtrack.jetbrains.com/issue/RUBY-16061
		used_composite = Marshal.load(Marshal.dump(composite))
		composite.each { |key, value|
			tags_with_composite[key] = value
		}
		with_composite = Scene.new(tags_with_composite, zlevel, on_water, type)
		composite = Scene.new(used_composite, zlevel, on_water, type)
		empty = Scene.new({}, zlevel, on_water, type)
		if with_composite.is_output_different(empty)
			if with_composite.is_output_different(composite)
				return true
			end
		end
		return false
	end
end
