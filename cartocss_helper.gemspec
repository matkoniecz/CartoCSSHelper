Gem::Specification.new do |s|
  s.name        = 'cartocss_helper'
  s.version     = '1.0.1'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Mateusz Konieczny']
  s.email       = ['matkoniecz@gmail.com']
  s.homepage    = 'https://github.com/matkoniecz/CartoCSSHelper'
  s.summary     = 'Tool to make development of CartoCSS styles more efficient.'
  s.description = 'Tool to make development of CartoCSS styles more efficient. Automates actions necessary to produce test images and validates style. Loading data using osm2pgsql, rendering with TileMill, obtaining test data from overpass turbo.'
  s.license     = 'CC0'

  s.required_rubygems_version = '>= 1.8.23'

  # If you have other dependencies, add them here
  #open3 is from stdlib
  #fileutils is from stdlib
  #find is from stdlib
  s.add_dependency 'rest-client', '~> 1.8.0'
  #digest/sha1 is from stdlib
  s.add_dependency 'sys-filesystem', '~> 1.1.4'
  #open3 is from stdlib
  #set is from stdlib
  s.add_dependency 'rmagick', '~> 2.15.2'

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir['{lib}/**/*.rb', 'bin/*', '*.txt', '*.md']
  s.require_path = 'lib'

end