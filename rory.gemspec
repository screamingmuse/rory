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

  spec.add_dependency "rack", "~> 2.2"
  spec.add_dependency "rack-contrib", "~> 2.5"
  spec.add_dependency "sequel", "~> 5.87"
  spec.add_dependency "thin", "~> 1.8"
  spec.add_dependency "thread-inheritable_attributes", "~> 2.0"
  spec.add_dependency "thor", "~> 1.3"

  spec.add_development_dependency "rake", "~> 13.2"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "mime-types", "~> 3.6"
  spec.add_development_dependency "capybara", "~> 3.40"
  spec.add_development_dependency "yard", "~> 0.9.37"
  spec.add_development_dependency "reek", "~> 6.3"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "pry", "~> 0.15.0"
end
