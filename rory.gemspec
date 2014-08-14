# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rory/version'

Gem::Specification.new do |s|
  s.name = "rory"
  s.version = Rory::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Ravi Gadad"]
  s.email = ["ravi@screamingmuse.com"]
  s.homepage = "http://github.com/screamingmuse/rory"
  s.summary = "Another Ruby web framework. Just what the world needs."
  s.description = <<-EOF
An exercise: Untangle the collusion of Rails idioms
from my Ruby knowledge, while trying to understand some
Rails design decisions.

See http://github.com/screamingmuse/rory for more info.
EOF
  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.extra_rdoc_files = ["LICENSE.txt", "README.md"]
  s.files = Dir['{lib/**/*,spec/**/*}'] +
                  %w(LICENSE.txt Rakefile README.md rory.gemspec)
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rack', '>= 1.0'
  s.add_runtime_dependency 'sequel', '~> 4.0'
  s.add_runtime_dependency 'thin', '~> 1.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'reek'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'bundler', '~> 1.0'
end

