# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'has_magic_fields/version'

Gem::Specification.new do |s|
  s.name          = "has_magic_fields"
  s.version       = HasMagicFields::VERSION
  s.authors       = ["ikeqiao"]
  s.email         = ["zhzsi@126.com"]
  s.description   = %q{Custom fields forActiveRecord models, suppport Rails 4!}
  s.summary       = %q{Allow addition of custom 'magic' fields to ActiveRecord models.}
  s.homepage      = "https://github.com/ikeqiao/has_magic_fields"
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|s|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_dependency("rails", [">= 4.0.0"])

end
