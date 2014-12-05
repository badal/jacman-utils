# encoding: utf-8

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)

require 'lib/jacman/core/version'

Gem::Specification.new do |s|
  s.name = "jacman-core-new"
  s.version = JacintheManagement::Core::VERSION
  s.authors = ["Michel Demazure"]
  s.description = "Core and Script tools for Jacinthe DB management"
  s.email = "michel@demazure.com"
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.files = ["README.md", "LICENSE", "MANIFEST"] + Dir.glob('{lib,spec}/**/*')
  s.homepage = "http://github/badal/jacman-core"
  s.require_paths = ["lib"]
  s.summary = "Core methods for Jacinthe DB management tools"

  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_development_dependency(%q<yard>, [">= 0"])
  s.add_development_dependency(%q<minitest>, [">= 0"])
  s.add_development_dependency(%q<minitest-reporters>, [">= 0"])

  s.add_runtime_dependency(%q<net-ssh>, [">= 0"])
  s.add_runtime_dependency(%q<net-scp>, [">= 0"])
  s.add_runtime_dependency(%q<net-sftp>, [">= 0"])
end
