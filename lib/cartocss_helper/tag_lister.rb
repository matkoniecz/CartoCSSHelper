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
      if @composite != nil
        string << ", #{@composite.to_s}"
      end
      string << '),'
      puts string
    end
  end

  class Info
    def self.get_expected_state(key, value)
      CartoCSSHelper::Configuration.get_style_specific_data.list_of_documented_tags.each { |documented|
        next unless documented.key == key
        if documented.value == value
          return documented.state
        end
      }
      return nil
    end

    def self.get_expected_composite(key, value)
      CartoCSSHelper::Configuration.get_style_specific_data.list_of_documented_tags.each { |documented|
        next unless documented.key == key
        if documented.value == value
          return documented.composite
        end
      }
      return nil
    end

    def print_render_state_of_tags(git_branch)
      Git.checkout git_branch
      get_render_state_of_tags.each { |state|
        state.code_print
      }
    end

    def get_render_state_of_tags(quick_and_more_prone_to_errors)
      states = []
      @last_composite = nil
      Heuristic.get_tags.each { |tag|
        key = tag[0]
        value = tag[1]
        # print_render_state_of_tag key, value
        state = get_render_state_of_tag(key, value, quick_and_more_prone_to_errors)
        states.push(TagRenderingStatus.new(key, value, state, @last_composite))
      }
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
      if notis_rendered key, get_generic_tag_value
        return false
      end
      [false, true].each { |on_water|
        [Configuration.get_max_z].each { |zlevel|
          ['area', 'closed_way', 'way', 'node'].each{ |type|
            next unless CartoCSSHelper::Info.rendered_on_zlevel({ key => value }, type, zlevel, on_water)
            if !is_key_rendered_and_value_ignored_set(key, value, type, zlevel, on_water)
              return false
            end
          }
        }
      }
      return true
    end

    def is_key_rendered_and_value_ignored_set(key, value, type, zlevel, on_water)
      with_tested_value = Scene.new({ key => value }, zlevel, on_water, type, true)
      with_generic_value = Scene.new({ key => get_generic_tag_value }, zlevel, on_water, type, true)
      return !with_tested_value.is_output_different(with_generic_value)
    end

    def is_rendered(key, value, zlevels = [Configuration.get_max_z]) # TODO: - note that some tags may be rendered up to X zoom level, but checking all zlevels would take too much time
      [false, true].each { |on_water|
        zlevels.each { |zlevel| #
          ['area', 'closed_way', 'way', 'node'].each{ |type|
            if CartoCSSHelper::Info.rendered_on_zlevel({ key => value }, type, zlevel, on_water)
              return true
            end
          }
        }
      }
      return false
    end

    def is_rendered_as_composite(key, value, suggested_composite = nil, zlevels = [Configuration.get_max_z]) # TODO: - note that some tags may be rendered up to X zoom level, but checking all zlevels would take too much time
      reason = how_rendered_as_composite key, value, suggested_composite, zlevels
      if reason == nil
        return false
      end
      return true
    end

    def how_rendered_as_composite(key, value, suggested_composite, zlevels = [Configuration.get_max_z]) # TODO: - note that some tags may be rendered up to X zoom level, but checking all zlevels would take too much time
      [false, true].each { |on_water|
        zlevels.each { |zlevel|
          result = how_rendered_on_zlevel_as_composite({ key => value }, 'closed_way', zlevel, on_water, suggested_composite)
          if result != nil
            return result
          end
          result = how_rendered_on_zlevel_as_composite({ key => value }, 'way', zlevel, on_water, suggested_composite)
          if result != nil
            return result
          end
          result = how_rendered_on_zlevel_as_composite({ key => value }, 'node', zlevel, on_water, suggested_composite)
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
      CartoCSSHelper::Configuration.get_style_specific_data.list_of_documented_compositions.each { |composite|
        if is_rendered_with_this_composite tags, type, composite, zlevel, on_water
          return composite
        end
      }
      return nil
    end

    def is_rendered_with_this_composite(tags, type, provided_composite, zlevel, on_water)
      # puts "<<<\n#{tags}\n#{composite}<<<\n\n"
      # noinspection RubyResolve
      # see https://youtrack.jetbrains.com/issue/RUBY-16061
      tags_with_composite = Marshal.load(Marshal.dump(tags))
      # noinspection RubyResolve
      # see https://youtrack.jetbrains.com/issue/RUBY-16061
      composite = Marshal.load(Marshal.dump(provided_composite))
      composite.each { |key, value|
        if tags_with_composite[key] != nil
          return false # shadowing
        end
        tags_with_composite[key] = value
      }
      with_composite = Scene.new(tags_with_composite, zlevel, on_water, type, true)
      only_composite = Scene.new(composite, zlevel, on_water, type, true)
      empty = Scene.new({}, zlevel, on_water, type, true)
      if with_composite.is_output_different(empty)
        if with_composite.is_output_different(only_composite)
          if composite['area'] != nil
            return true
          end
          composite['area'] = 'yes'
          composite_interpreted_as_area = Scene.new(composite, zlevel, on_water, type, true)
          if with_composite.is_output_different(composite_interpreted_as_area)
            return true
          end
        end
      end
      return false
    end
  end
end
