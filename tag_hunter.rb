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
	return tags
end