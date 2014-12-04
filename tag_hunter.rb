require 'set'

def get_tags
	tags = get_tags_from_mss
	tags.merge(get_tags_from_yaml)
	tags.merge(get_tags_from_osm2pqsql)
	unrecovable = Set.new [['area', 'yes'], ['area', 'no']]
	tags.merge(unrecovable)
	return tags.to_a.sort
end

def get_tags_from_mss
	tags = Set.new
	filenames = Dir[get_style_path+'*.mss']
	filenames.each { |filename|
		tags.merge(get_tags_from_mss_file filename)
	}
	return tags
end

def get_tags_from_yaml
	tags = Set.new
	filenames = Dir[get_style_path+'*.yaml']
	filenames.each { |filename|
		tags.merge(get_tags_from_yaml_file filename)
	}
	return  tags
end

def get_tags_from_osm2pqsql
	tags = Set.new
	filenames = Dir[get_style_path+'*.style']
	filenames.each { |filename|
		tags.merge(get_tags_from_osm2pqsql_file filename)
	}
	return  tags
end

def get_tags_from_mss_file(style_filename)
	tags = Set.new
	#puts style_filename
	style_file = open(style_filename)
	style = style_file.read
	matched = style.scan(/\[feature = '(man_made|[^_]+)_([^']+)'\]/)
	matched.each { |element|
		tags.add([element[0], element[1]])
	}
	return tags
end

def get_tags_from_yaml_file(yaml_filename)
	tags = Set.new
	yaml_file = open(yaml_filename)
	yaml = yaml_file.read
	#(.*\.|)     #WHERE p.highway = 'turning_circle'
	#("|)        #natural and other SQL keywords
	#([^"() ]+)  #tag
	#repeat
	# = 
	#'([^'()]+)' #quoted value
	matched = yaml.scan(/(.*\.|)("|)([^"() ]+)("|) = '([^'()]+)'/)
	matched.each { |element|
		tags.add([element[2], element[4]])
	}
	matched = yaml.scan(/("|)([^"() ]+)("|) (NOT |)IN \(([^()]*)\)/)
	matched.each { |element|
		tag = element[1]
		tag = tag.gsub(/.*\./, '')
		values = element[4]
		values_matched = values.scan(/'([^']+)'/)
		values_matched.each { |value|
			tags.add([tag, value[0]])
		}
	}
	return tags
end

def get_generic_tag_value
	return '*'
end

def get_tags_from_osm2pqsql_file(style_filename)
	tags = Set.new
	#puts style_filename
	style_file = open(style_filename)
	style = style_file.read
	matched = style.scan(/^(node,way|node|way)   ([^ ]+)/)
	matched.each { |element|
		tags.add([element[1], get_generic_tag_value])
	}
	return tags
end