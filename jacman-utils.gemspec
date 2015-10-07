# encoding: utf-8

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)

require 'lib/jacman/utils/version'

Gem::Specification.new do |s|
  s.name = 'jacman-utils'
  s.version = JacintheManagement::Utils::VERSION
  s.authors = ['Michel Demazure']
  s.description = 'Core and Script tools for Jacinthe DB management'
  s.email = 'michel@demazure.com'
  s.extra_rdoc_files = ['README.md', 'LICENSE', 'MANIFEST']
  s.files = ['README.md', 'LICENSE', 'MANIFEST'] + Dir.glob('{lib,spec}/**/*')
  s.homepage = 'http://github/badal/jacman-core'
  s.require_paths = ['lib']
  s.summary = 'Core methods for Jacinthe DB management tools'
  s.license = 'MIT'

  s.add_dependency('mail', ['>=0'])

  s.add_development_dependency('rake', ['>= 0'])
  s.add_development_dependency('yard', ['>= 0'])
  s.add_development_dependency('minitest', ['>= 0'])
  s.add_development_dependency('minitest-reporters', ['>= 0'])
end
