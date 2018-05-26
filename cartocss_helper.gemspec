# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'cartocss_helper'
  s.version     = '5.0.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Mateusz Konieczny']
  s.email       = ['matkoniecz@gmail.com']
  s.homepage    = 'https://github.com/matkoniecz/CartoCSSHelper'
  s.summary     = 'Tool to make development of CartoCSS styles more efficient.'
  s.description = 'Tool to make development of CartoCSS styles more efficient. Automates actions necessary to produce test images and validates style. Loading data using osm2pgsql, rendering with TileMill, obtaining test data from overpass turbo.'
  s.license     = 'CC0'

  s.required_rubygems_version = '>= 1.8.23'

  # https://en.wikipedia.org/wiki/Ruby_(programming_language)#Table_of_versions
  # update also versions in
  # .travis.yml
  # .rubocop.yml (TargetRubyVersion)
  s.required_ruby_version = '>= 2.3.0'

  # If you have other dependencies, add them here
  # open3 is from stdlib
  # fileutils is from stdlib
  # find is from stdlib
  s.add_dependency 'rest-client', '~> 2.0'
  # digest/sha1 is from stdlib
  s.add_dependency 'sys-filesystem', '~> 1.1', '>= 1.1.0'
  # open3 is from stdlib
  # set is from stdlib
  s.add_dependency 'rmagick', '~> 2.0'
  s.add_dependency 'ruby-progressbar', '~> 1.8'

  s.add_development_dependency 'rspec', '~> 3.4', '>= 3.4.0'
  s.add_development_dependency 'rubocop', '~> 0.52', '> 0.48.1'
  s.add_development_dependency 'simplecov', '~> 0.11'
  s.add_development_dependency 'travis', '~> 1.8'

  # Required by codeclimate, see https://docs.codeclimate.com/docs/setting-up-test-coverage#how-to for docs.
  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.5'

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir['{lib}/**/*.rb', 'bin/*', '*.txt', '*.md']
  s.require_path = 'lib'
end

=begin
how to release new gem version:

rm cartocss_helper-*.*.*.gem
gem build cartocss_helper.gemspec
gem install cartocss_helper-*.*.*.gem --user-install
gem push cartocss_helper-*.*.*.gem

=end
