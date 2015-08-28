# encoding: UTF-8
require_relative 'heuristic.rb'
require_relative 'image_generator.rb'
require_relative 'configuration.rb'
require_relative 'tag_lister.rb'

include CartoCSSHelper::Heuristic
include CartoCSSHelper::Configuration

module CartoCSSHelper
  module Validator
    def run_tests(git_branch)
      run_dy_test(git_branch)
      run_expected_rendering_test(git_branch, true)
      run_closed_way_test(git_branch)
      run_expected_rendering_test(git_branch)
    end

    def run_expected_rendering_test(git_branch, quick_and_more_prone_to_errors=false)
      Git.checkout git_branch
      puts 'unexpectedly rendered/unrendered keys:'
      compare_expected_with_real_rendering(quick_and_more_prone_to_errors)
      puts
    end

    def run_dy_test(git_branch)
      Git.checkout git_branch
      puts "bad dy values (tall names like 'É' are not displayed, short names like 'a' are):"
      run_global_check(:check_dy)
      puts
    end

    def run_closed_way_test(git_branch)
      Git.checkout git_branch
      puts 'failed display of closed way, unlosed way works:'
      run_global_check(:check_problems_with_closed_line)
      puts
    end

    def compare_expected_with_real_rendering(quick_and_more_prone_to_errors=false)
      list_of_documented = CartoCSSHelper::Configuration.get_style_specific_data.list_of_documented_tags
      info = Info.new
      list_of_rendered = info.get_render_state_of_tags(quick_and_more_prone_to_errors)

      ensure_that_tags_documented_and_rendered_have_the_same_state(list_of_documented, list_of_rendered)
      ensure_that_all_rendered_tags_are_documented(list_of_documented, list_of_rendered)
      ensure_that_all_documented_are_really_rendered(list_of_documented, list_of_rendered)
    end

    def ensure_that_tags_documented_and_rendered_have_the_same_state(list_of_documented, list_of_rendered)
      list_of_rendered.each { |tag_info|
        compare_expected_with_tag_data list_of_documented, tag_info
      }
    end

    def ensure_that_all_rendered_tags_are_documented(list_of_documented, list_of_rendered)
      list_of_rendered.each { |tag_info|
        if tag_info.state != :ignored
          if !is_tag_documented(list_of_documented, tag_info.key, tag_info.value)
            puts 'documented'
            puts "\tmissing"
            puts 'real'
            print "\t"
            tag_info.print
            puts
          end
        end
      }
    end

    def ensure_that_all_documented_are_really_rendered(list_of_documented, list_of_rendered)
      list_of_documented.each { |documented|
        if !is_tag_documented(list_of_rendered, documented.key, documented.value)
          puts 'documented'
          print "\t"
          documented.print
          puts 'real'
          puts "\tmissing"
          puts
        end
      }
    end

    def is_tag_documented(list, key, value)
      list.each { |tag_info|
        if key == tag_info.key
          if value == tag_info.value
            return true
          end
        end
      }
      return false
    end

    def compare_expected_with_tag_data(list_of_expected, tag_info)
      list_of_expected.each { |expected|
        if expected.key == tag_info.key
          if expected.value == tag_info.value
            if expected.equal? tag_info
              puts 'expected'
              print "\t"
              expected.print
              puts 'real'
              print "\t"
              tag_info.print
              puts
            end
            return
          end
        end
      }
    end

    def run_global_check(function)
      Heuristic.get_tags.each { |element|
        (Configuration.get_max_z..Configuration.get_max_z).each { |zlevel| #get_min_z should be used - but as renderer is extremely slow this hack was used TODO
          send(function, element[0], element[1], zlevel)
        }
      }
    end

    #TODO - what about composite tags?
    def check_problems_with_closed_line(key, value, zlevel, on_water = false)
      way = Scene.new({key => value}, zlevel, on_water, 'way')
      closed_way = Scene.new({key => value}, zlevel, on_water, 'closed_way')
      empty = Scene.new({}, zlevel, on_water, 'node')
      if way.is_output_different(empty)
        if !closed_way.is_output_different(empty)
          puts key+'='+value
        end
      end
    end

    def check_dy(key, value, zlevel, interactive=false, on_water=false)
      if !is_object_displaying_anything key, value, zlevel, on_water
        #puts key+"="+value+" - not displayed as node on z#{zlevel}"
        return
      end
      if !is_object_displaying_name key, value, 'a', zlevel, on_water
        #puts key+"="+value+" - label is missing on z#{zlevel} nodes"
        return
      end
      test_name = 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ'
      while !is_object_displaying_name key, value, test_name, zlevel, on_water
        puts key+'='+value+" - name is missing for name '#{test_name}' on z#{zlevel}"
        if interactive
          puts 'press enter'
          gets
        else
          return
        end
        with_name = Scene.new({key => value, 'name' => test_name}, zlevel, on_water, 'node')
        with_name.flush_cache
        puts 'calculating'
      end
      #puts key+"="+value+" - name is OK for name '#{name}'"
    end

    def is_object_displaying_name(key, value, name, zlevel, on_water)
      name_tags = {key => value, 'name' => name}
      with_name = Scene.new(name_tags, zlevel, on_water, 'node')
      nameless_tags = {key => value}
      nameless = Scene.new(nameless_tags, zlevel, on_water, 'node')
      return with_name.is_output_different(nameless)
    end

    def is_object_displaying_anything(key, value, zlevel, on_water)
      object = Scene.new({key => value}, zlevel, on_water, 'node')
      empty = Scene.new({}, zlevel, on_water, 'node')
      return object.is_output_different(empty)
    end
  end
end
