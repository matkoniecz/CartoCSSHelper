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
      run_missing_name_test(git_branch)
      run_expected_rendering_test(git_branch, true)
      run_closed_way_test(git_branch)
      run_expected_rendering_test(git_branch)
      run_unwanted_name_test(git_branch)
    end

    def run_expected_rendering_test(git_branch, quick_and_more_prone_to_errors = false)
      Git.checkout git_branch
      puts 'unexpectedly rendered/unrendered keys:'
      compare_expected_with_real_rendering(quick_and_more_prone_to_errors)
      puts
    end

    def run_missing_name_test(git_branch)
      Git.checkout git_branch
      puts 'Check whatever names are displayed:'
      run_global_check(:check_missing_names)
      puts
    end

    def run_unwanted_name_test(git_branch)
      Git.checkout git_branch
      puts 'Check whatever names are displayed:'
      run_global_check(:check_unwanted_names)
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

    def compare_expected_with_real_rendering(quick_and_more_prone_to_errors = false)
      list_of_documented = CartoCSSHelper::Configuration.get_style_specific_data.list_of_documented_tags
      info = Info.new
      list_of_rendered = info.get_render_state_of_tags(quick_and_more_prone_to_errors)

      puts 'ensure_that_tags_documented_and_rendered_have_the_same_state'
      ensure_that_tags_documented_and_rendered_have_the_same_state(list_of_documented, list_of_rendered)

      puts 'ensure_that_all_rendered_tags_are_documented'
      ensure_that_all_rendered_tags_are_documented(list_of_documented, list_of_rendered)

      puts 'ensure_that_all_documented_are_really_rendered'
      ensure_that_all_documented_are_really_rendered(list_of_documented, list_of_rendered)
    end

    def ensure_that_tags_documented_and_rendered_have_the_same_state(list_of_documented, list_of_rendered)
      list_of_rendered.each do |tag_info|
        compare_expected_with_tag_data list_of_documented, tag_info
      end
    end

    def ensure_that_all_rendered_tags_are_documented(list_of_documented, list_of_rendered)
      list_of_rendered.each do |tag_info|
        next if is_tag_documented(list_of_documented, tag_info.key, tag_info.value)
        puts 'documented'
        puts "\tmissing"
        puts 'real'
        print "\t"
        tag_info.print
        puts
      end
    end

    def ensure_that_all_documented_are_really_rendered(list_of_documented, list_of_rendered)
      list_of_documented.each do |documented|
        if Info.get_expected_state(documented.key, documented.value) == :ignored
          next
        end
        next if is_tag_documented(list_of_rendered, documented.key, documented.value)
        puts 'documented'
        print "\t"
        documented.print
        puts 'real'
        puts "\tmissing"
        puts
      end
    end

    def is_tag_documented(list, key, value)
      list.each do |tag_info|
        next unless key == tag_info.key
        return true if value == tag_info.value
      end
      return false
    end

    def compare_expected_with_tag_data(list_of_expected, tag_info)
      list_of_expected.each do |expected|
        next unless expected.key == tag_info.key
        next unless expected.value == tag_info.value
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

    def run_global_check(function)
      Heuristic.get_tags.each do |element|
        key = element[0]
        value = element[1]
        state = Info.get_expected_state(key, value)
        tags = { key => value }
        next if state == :ignore
        if state == :composite
          tags.merge!(Info.get_expected_composite(key, value))
        end
        (Configuration.get_max_z..Configuration.get_max_z).each do |zlevel| # get_min_z should be used - but as renderer is extremely slow this hack was used TODO
          send(function, tags, zlevel)
        end
      end
    end

    def check_problems_with_closed_line(tags, zlevel, on_water = false)
      way = Scene.new(tags, zlevel, on_water, 'way', true)
      closed_way = Scene.new(tags, zlevel, on_water, 'closed_way', true)
      empty = Scene.new({}, zlevel, on_water, 'node', true)
      if way.is_output_different(empty)
        puts tags unless closed_way.is_output_different(empty)
      end
    end

    def check_missing_names(tags, zlevel, interactive = false, on_water = false)
      not_required = CartoCSSHelper::Configuration.get_style_specific_data.name_label_is_not_required
      return if not_required.include?(tags)
      ['node', 'closed_way', 'way'].each do |type|
        next if not_required.include?(tags.merge({ type: type }))
        unless is_object_displaying_anything_as_this_object_type tags, zlevel, on_water, type
          # puts key+"="+value+" - not displayed as node on z#{zlevel}"
          next
        end
        tags.delete('name') if tags['name'] != nil
        unless is_object_displaying_name_as_this_object_type tags, 'a', zlevel, on_water, type
          puts "#{tags} - label is missing on z#{zlevel} #{type}"
          next
        end
      end
    end

    def check_unwanted_names(tags, zlevel, interactive = false, on_water = false)
      ['node', 'closed_way', 'way'].each do |type|
        not_required = CartoCSSHelper::Configuration.get_style_specific_data.name_label_is_not_required
        next unless not_required.include?(tags) or not_required.include?(tags.merge({ type: type }))
        unless is_object_displaying_anything_as_this_object_type tags, zlevel, on_water, type
          # puts key+"="+value+" - not displayed as node on z#{zlevel}"
          next
        end
        tags.delete('name') if tags['name'] != nil
        if is_object_displaying_name_as_this_object_type tags, 'a', zlevel, on_water, type
          puts "#{tags} - label is unxpectedly displayed on z#{zlevel} #{type}"
        end
      end
    end

    def check_dy(tags, zlevel, interactive = false, on_water = false)
      unless is_object_displaying_anything_as_node tags, zlevel, on_water
        # puts key+"="+value+" - not displayed as node on z#{zlevel}"
        return
      end
      unless is_object_displaying_name_as_node tags, 'a', zlevel, on_water
        # puts key+"="+value+" - label is missing on z#{zlevel} nodes"
        return
      end
      test_name = 'ÉÉÉÉÉÉ ÉÉÉÉÉÉ ÉÉÉÉÉÉ'
      until is_object_displaying_name_as_node tags, test_name, zlevel, on_water
        puts "#{tags} - name is missing for name '#{test_name}' on z#{zlevel}"
        if interactive
          puts 'press enter'
          gets
        else
          return
        end
        with_name = Scene.new({ key => value, 'name' => test_name }, zlevel, on_water, 'node', true)
        with_name.flush_cache
        puts 'calculating'
      end
      # puts key+"="+value+" - name is OK for name '#{name}'"
    end

    def is_object_displaying_name_as_this_object_type(tags, name, zlevel, on_water, type)
      name_tags = tags.merge({ 'name' => name })
      with_name = Scene.new(name_tags, zlevel, on_water, type, true)
      nameless_tags = tags
      nameless = Scene.new(nameless_tags, zlevel, on_water, type, true)
      return with_name.is_output_different(nameless)
    end

    def is_object_displaying_name_as_node(tags, name, zlevel, on_water)
      is_object_displaying_name_as_this_object_type(tags, name, zlevel, on_water, 'node')
    end

    def is_object_displaying_anything_as_this_object_type(tags, zlevel, on_water, type)
      object = Scene.new(tags, zlevel, on_water, type, true)
      empty = Scene.new({}, zlevel, on_water, type, true)
      return object.is_output_different(empty)
    end

    def is_object_displaying_anything_as_node(tags, zlevel, on_water)
      return is_object_displaying_anything_as_this_object_type(tags, zlevel, on_water, 'node')
    end
  end
end
