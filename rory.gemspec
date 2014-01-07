# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rory/version'

Gem::Specification.new do |s|
  s.name = "rory"
  s.version = Rory::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Ravi Gadad"]
  s.email = ["ravi@renewfund.com"]
  s.homepage = "http://github.com/renewablefunding/rory"
  s.summary = "Another Ruby web framework. Just what the world needs."
  s.description = <<-EOF
An exercise: Untangle the collusion of Rails idioms
from my Ruby knowledge, while trying to understand some
Rails design decisions.

See http://github.com/renewablefunding/rory for more info.
EOF
  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.executables = ["rory"]
  s.extra_rdoc_files = ["LICENSE.txt", "README.rdoc"]
  s.files = Dir['{bin/*,lib/**/*,spec/**/*}'] +
                  %w(LICENSE.txt Rakefile README.rdoc rory.gemspec)
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rack'
  s.add_runtime_dependency 'sequel'
  s.add_runtime_dependency 'thin'
  s.add_runtime_dependency 'rake'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'reek'
end

