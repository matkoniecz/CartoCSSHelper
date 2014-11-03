require 'set'

def get_tags
	tags = get_tags_from_mss
	tags.merge(get_tags_from_yaml)
	tags.merge(get_tags_from_osm2pqsql)
	return tags.to_a.sort
end

def get_tags_from_mss
	tags = Set.new
	filenames = Dir[get_style_path+'*.mss']
	for filename in filenames
		tags.merge(get_tags_from_mss_file filename)
	end
	return tags
end

def get_tags_from_yaml
	tags = Set.new
	filenames = Dir[get_style_path+'*.yaml']
	for filename in filenames
		tags.merge(get_tags_from_yaml_file filename)
	end
	return  tags
end

def get_tags_from_osm2pqsql
	tags = Set.new
	filenames = Dir[get_style_path+'*.style']
	for filename in filenames
		tags.merge(get_tags_from_osm2pqsql_file filename)
	end
	return  tags
end

def get_tags_from_mss_file style_filename
	tags = Set.new
	#puts style_filename
	style_file = open(style_filename)
	style = style_file.read()
	matched = style.scan(/\[feature = '(man_made|[^_]+)_([^']+)'\]/)
	for element in matched
		tags.add([element[0], element[1]])
	end
	return tags
end

def get_tags_from_yaml_file yaml_filename
	tags = Set.new
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
	matched = yaml.scan(/("|)([^"() ]+)("|) (NOT |)IN \(([^()]*)\)/)
	for element in matched
		tag = element[1]
		tag = tag.gsub(/.*\./, "")
		values = element[4]
		values_matched = values.scan(/'([^']+)'/)
		for value in values_matched
			tags.add([tag, value[0]])
		end
	end
	return tags
end

def get_tags_from_osm2pqsql_file style_filename
	tags = Set.new
	#puts style_filename
	style_file = open(style_filename)
	style = style_file.read()
	matched = style.scan(/^(node,way|node|way)   ([^ ]+)/)
	for element in matched
		tags.add([element[1], "any_tag_value"])
	end
	return tags
end