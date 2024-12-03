# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rory/version"

Gem::Specification.new do |spec|
  spec.name = "rory"
  spec.version = Rory::VERSION
  spec.authors = ["Ravi Gadad", "Michael Irey", "David Begin", "Dustin Zeisler"]
  spec.email = ["ravi@screamingmuse.com"]

  spec.summary = "Another Ruby web framework. Just what the world needs."
  spec.homepage = "http://github.com/screamingmuse/rory"
  spec.description = <<-EOF
An exercise: Untangle the collusion of Rails idioms
from my Ruby knowledge, while trying to understand some
Rails design decisions.

See http://github.com/screamingmuse/rory for more info.
EOF
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_dependency "rack-contrib"
  spec.add_dependency "sequel"
  spec.add_dependency "thin"
  spec.add_dependency "thread-inheritable_attributes"
  spec.add_dependency "thor"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "mime-types"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "reek"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
end
