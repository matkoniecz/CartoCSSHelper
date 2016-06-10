require_relative 'configuration.rb'
require_relative 'image_generator.rb'
include CartoCSSHelper::Configuration
include CartoCSSHelper::Heuristic

module CartoCSSHelper
  class TagRenderingStatus
    attr_accessor :key, :value, :state, :composite
    def initialize(key, value, state, composite = nil)
      @key = key
      @value = value
      @state = state
      @composite = composite
    end

    def print
      composite_string = ''
      if composite
        composite_string = "- rendered with #{@composite.to_s.gsub('=>', '=')}, maybe also other sets of tags"
      end
      puts "#{@key}=#{@value} #{@state} #{composite_string}"
    end

    def code_print
      string = "Status.new('#{@key}', '#{@value}', :#{@state}"
      string << ", #{@composite.to_s}" if @composite != nil
      string << '),'
      puts string
    end
  end

  class Info
    def self.get_expected_state(key, value)
      CartoCSSHelper::Configuration.get_style_specific_data.list_of_documented_tags.each do |documented|
        next unless documented.key == key
        return documented.state if documented.value == value
      end
      return nil
    end

    def self.get_expected_composite(key, value)
      CartoCSSHelper::Configuration.get_style_specific_data.list_of_documented_tags.each do |documented|
        next unless documented.key == key
        return documented.composite if documented.value == value
      end
      return nil
    end

    def print_render_state_of_tags(git_branch)
      Git.checkout git_branch
      get_render_state_of_tags.each do |state|
        state.code_print
      end
    end

    def get_render_state_of_tags(quick_and_more_prone_to_errors)
      states = []
      @last_composite = nil
      Heuristic.get_tags.each do |tag|
        key = tag[0]
        value = tag[1]
        # print_render_state_of_tag key, value
        state = get_render_state_of_tag(key, value, quick_and_more_prone_to_errors)
        states.push(TagRenderingStatus.new(key, value, state, @last_composite))
      end
      return states
    end

    def get_render_state_of_tag(key, value, quick_and_more_prone_to_errors)
      if Info.get_expected_state(key, value) == :ignored
        @last_composite = nil
        return :ignored
      end
      zlevels = [22, 13] # TODO: - this is specially tuned for Default
      expected_composite = Info.get_expected_composite(key, value)
      if quick_and_more_prone_to_errors
        return get_render_state_of_tag_quick_heurestic(key, value, expected_composite, zlevels)
      end
      return get_render_state_of_tag_thorough(key, value, expected_composite, zlevels)
    end

    def get_render_state_of_tag_quick_heurestic
      if expected_composite != nil
        if is_rendered_as_composite key, value, expected_composite, zlevels
          @last_composite = how_rendered_as_composite key, value, expected_composite, zlevels
          return :composite
        else
          @last_composite = nil
          return :ignored
        end
      else
        if is_rendered key, value, zlevels
          @last_composite = nil
          return :primary
        else
          @last_composite = nil
          return :ignored
        end
      end
    end

    def get_render_state_of_tag_thorough(key, value, expected_composite, zlevels)
      if is_rendered key, value, zlevels
        @last_composite = nil
        return :primary
      else
        if is_rendered_as_composite key, value, expected_composite
          @last_composite = how_rendered_as_composite key, value, expected_composite
          return :composite
        else
          @last_composite = nil
          return :ignored
        end
      end
    end

    def print_render_state_of_tag(key, value)
      if is_rendered key, value
        @last_composite = nil
        if value == get_generic_tag_value
          puts "#{key}=#{value} - primary generic tag value"
        elsif is_key_rendered_and_value_ignored(key, value)
          puts "#{key}=#{value} - primary, but rendering the same as generic value"
        else
          puts "#{key}=#{value} - primary"
        end
      else
        if is_rendered_as_composite key, value, @last_composite
          @last_composite = how_rendered_as_composite key, value, @last_composite
          puts "#{key}=#{value} - composite with #{@last_composite} - and maybe other tags"
        else
          @last_composite = nil
          puts "#{key}=#{value} - not displayed"
        end
      end
    end

    def is_key_rendered_and_value_ignored(key, value)
      return false if notis_rendered key, get_generic_tag_value
      [false, true].each do |on_water|
        [Configuration.get_max_z].each do |zlevel|
          ['area', 'closed_way', 'way', 'node'].each do |type|
            next unless CartoCSSHelper::Info.rendered_on_zlevel({ key => value }, type, zlevel, on_water)
            unless is_key_rendered_and_value_ignored_set(key, value, type, zlevel, on_water)
              return false
            end
          end
        end
      end
      return true
    end

    def is_key_rendered_and_value_ignored_set(key, value, type, zlevel, on_water)
      with_tested_value = Scene.new({ key => value }, zlevel, on_water, type, true)
      with_generic_value = Scene.new({ key => get_generic_tag_value }, zlevel, on_water, type, true)
      return !with_tested_value.is_output_different(with_generic_value)
    end

    def is_rendered(key, value, zlevels = [Configuration.get_max_z]) # TODO: - note that some tags may be rendered up to X zoom level, but checking all zlevels would take too much time
      [false, true].each do |on_water|
        zlevels.each do |zlevel| #
          ['area', 'closed_way', 'way', 'node'].each do |type|
            if CartoCSSHelper::Info.rendered_on_zlevel({ key => value }, type, zlevel, on_water)
              return true
            end
          end
        end
      end
      return false
    end

    def is_rendered_as_composite(key, value, suggested_composite = nil, zlevels = [Configuration.get_max_z]) # TODO: - note that some tags may be rendered up to X zoom level, but checking all zlevels would take too much time
      reason = how_rendered_as_composite key, value, suggested_composite, zlevels
      return false if reason == nil
      return true
    end

    def how_rendered_as_composite(key, value, suggested_composite, zlevels = [Configuration.get_max_z]) # TODO: - note that some tags may be rendered up to X zoom level, but checking all zlevels would take too much time
      [false, true].each do |on_water|
        zlevels.each do |zlevel|
          result = how_rendered_on_zlevel_as_composite({ key => value }, 'closed_way', zlevel, on_water, suggested_composite)
          return result if result != nil
          result = how_rendered_on_zlevel_as_composite({ key => value }, 'way', zlevel, on_water, suggested_composite)
          return result if result != nil
          result = how_rendered_on_zlevel_as_composite({ key => value }, 'node', zlevel, on_water, suggested_composite)
          return result if result != nil
        end
      end
      if suggested_composite != nil
        return how_rendered_as_composite key, value, nil
      end
      return nil
    end

    def self.rendered_on_zlevel(tags, type, zlevel, on_water)
      empty = Scene.new({}, zlevel, on_water, type, true)
      tested = Scene.new(tags, zlevel, on_water, type, true)
      return tested.is_output_different(empty)
    end

    protected

    def how_rendered_on_zlevel_as_composite(tags, type, zlevel, on_water, suggested_composite)
      if suggested_composite != nil
        if is_rendered_with_this_composite tags, type, suggested_composite, zlevel, on_water
          return suggested_composite
        end
        return nil
      end
      CartoCSSHelper::Configuration.get_style_specific_data.list_of_documented_compositions.each do |composite|
        if is_rendered_with_this_composite tags, type, composite, zlevel, on_water
          return composite
        end
      end
      return nil
    end

    def deep_clone(input)
      return Marshal.load(Marshal.dump(input))
    end

    def is_rendered_with_this_composite(tags, type, provided_composite, zlevel, on_water)
      tags_with_composite = deep_clone(tags)
      composite = deep_clone(provided_composite)
      composite.each do |key, value|
        if tags_with_composite[key] != nil
          return false # shadowing
        end
        tags_with_composite[key] = value
      end
      with_composite = Scene.new(tags_with_composite, zlevel, on_water, type, true)
      only_composite = Scene.new(composite, zlevel, on_water, type, true)
      empty = Scene.new({}, zlevel, on_water, type, true)
      return false if with_composite.is_output_identical(empty)
      return false if with_composite.is_output_identical(only_composite)
      return true if composite['area'] != nil
      composite['area'] = 'yes'
      composite_interpreted_as_area = Scene.new(composite, zlevel, on_water, type, true)
      return false if with_composite.is_output_identical(composite_interpreted_as_area)
      return true
    end
  end
end
