# frozen_string_literal: true

module CartoCSSHelper
  module Heuristic
    require 'set'
    require_relative 'configuration.rb'
    include CartoCSSHelper::Configuration
    def get_tags
      tags = get_tags_from_mss
      tags.merge(get_tags_from_yaml)
      tags.merge(get_tags_from_osm2pqsql)
      # unrecovable = Set.new [['area', 'yes'], ['area', 'no']] #TODO - how this should be handled?
      # tags.merge(unrecovable)
      return tags.to_a.sort
    end

    def get_tags_from_mss
      tags = Set.new
      filenames = Dir[Configuration.get_path_to_cartocss_project_folder + '*.mss']
      filenames.each do |filename|
        tags.merge(get_tags_from_mss_file(filename))
      end
      return tags
    end

    def get_tags_from_yaml
      tags = Set.new
      filenames = Dir[Configuration.get_path_to_cartocss_project_folder + '*.yaml']
      filenames.each do |filename|
        tags.merge(get_tags_from_yaml_file(filename))
      end
      return tags
    end

    def get_tags_from_osm2pqsql
      tags = Set.new
      filenames = Dir[Configuration.get_path_to_cartocss_project_folder + '*.style']
      filenames.each do |filename|
        tags.merge(get_tags_from_osm2pqsql_file(filename))
      end
      return tags
    end

    def get_tags_from_mss_file(style_filename)
      possible_key_values = get_tags_from_osm2pqsql
      tags = Set.new
      # puts style_filename
      style_file = open(style_filename)
      style = style_file.read
      matched = style.scan(/\[feature = '(man_made|[^_]+)_([^']+)'\]/)
      matched.each do |element|
        key = element[0]
        if possible_key_values.include?([key, get_generic_tag_value])
          tags.add([key, element[1]])
        end
      end
      matched = style.scan(/(\w+) = '(\w+)'/)
      matched.each do |element|
        key = element[0]
        next unless key != 'feature'
        if possible_key_values.include?([key, get_generic_tag_value])
          tags.add([key, element[1]])
        end
      end
      return tags
    end

    def get_tags_from_yaml_file(yaml_filename)
      possible_key_values = get_tags_from_osm2pqsql
      tags = Set.new
      yaml_file = open(yaml_filename)
      yaml = yaml_file.read
      # (.*\.|)     #WHERE p.highway = 'turning_circle'
      # ("|)        #natural and other SQL keywords
      # ([^"() ]+)  #tag
      # repeat
      # =
      # '([^'()]+)' #quoted value
      matched = yaml.scan(/(.*\.|)("|)([^"() ]+)("|) = '([^'()]+)'/)
      matched.each do |element|
        key = element[2]
        value = element[4]
        if possible_key_values.include?([key, get_generic_tag_value])
          tags.add([key, value])
        end
      end
      matched = yaml.scan(/("|)([^"() ]+)("|) (NOT |)IN \(([^()]*)\)/)
      matched.each do |element|
        tag = element[1]
        key = tag.gsub(/.*\./, '')
        values = element[4]
        values_matched = values.scan(/'([^']+)'/)
        next unless possible_key_values.include?([key, get_generic_tag_value])
        values_matched.each do |value|
          tags.add([key, value[0]])
        end
      end
      return tags
    end

    def self.get_generic_tag_value
      return '*'
    end

    def get_tags_from_osm2pqsql_file(style_filename)
      tags = Set.new
      # puts style_filename
      style_file = open(style_filename)
      style = style_file.read
      matched = style.scan(/^(node,way|node|way)\s*([^ ]+)\s*text\s*($|linear|polygon|nocache)/)
      matched.each do |element|
        tags.add([element[1], get_generic_tag_value])
      end
      return tags
    end
  end
end
