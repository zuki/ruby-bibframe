# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bibframe/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-bibframe"
  spec.version       = Bibframe::VERSION
  spec.authors       = ["Keiji Suzuki"]
  spec.email         = ["zuki.ebetsu@gmail.com"]
  spec.summary       = %q{Bibframe converter for Ruby.}
  spec.description   = %q{Bibframe is a Bibframe converter for the MARC records.}
  spec.homepage      = "https://github.com/zuki/ruby-bibframe"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'marc'
  spec.add_runtime_dependency 'rdf', "~> 1.1.4"
  spec.add_runtime_dependency 'iso-639'
  spec.add_runtime_dependency 'uuid'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
