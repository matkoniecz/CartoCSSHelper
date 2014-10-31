require 'set'

def get_tags
	tags = Set.new
	style_filenames = Dir[get_style_path+'*.mss']
	for style_filename in style_filenames
		#puts style_filename
		style_file = open(style_filename)
		style = style_file.read()
		matched = style.scan(/\[feature = '(man_made|[^_]+)_([^']+)'\]/)
		for element in matched
			tags.add([element[0], element[1]])
		end
	end
	yaml_filename = get_style_path+'project.yaml'
	yaml_file = open(yaml_filename)
	yaml = yaml_file.read()
	#(.*\.|)     #WHERE p.highway = 'turning_circle'
	#("|)        #natural and other SQL keywords
	#([^"() ]+)  #tag
	#repeat
	# = 
	#'([^'()]+)' #quoted value
	matched = yaml.scan(/(.*\.|)("|)([^"() ]+)("|) = '([^'()]+)'/)
	for element in matched
		tags.add([element[2], element[4]])
	end
	matched = yaml.scan(/("|)([^"() ]+)("|) IN \(([^()]*)\)/)
	for element in matched
		tag = element[1]
		tag = tag.gsub(/.*\./, "")
		values = element[3]
		values_matched = values.scan(/'([^']+)'/)
		for value in values_matched
			tags.add([tag, value[0]])
		end
	end
	return tags.to_a.sort
end
