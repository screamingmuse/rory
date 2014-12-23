ENV['RORY_ENV'] ||= ENV['RORY_STAGE'] || ENV['RACK_ENV'] || 'development'

if ENV['RORY_STAGE']
  puts "\n\tDEPRECATION: use 'RORY_ENV' instead of 'RORY_STAGE'\n\n"
else
  # Set RORY_STAGE to the default as well, since people might
  # still be using it
  ENV['RORY_STAGE'] = ENV['RORY_ENV']
end

require 'yaml'
require 'sequel'
require 'rory/hash_with_dubious_semantics'
require 'rory/application'
require 'rory/dispatcher'
require 'rory/route'
require 'rory/support'
require 'rory/controller'

module Rory
  class << self
    attr_accessor :application

    def root
      app = application
      app && app.root
    end
  end
end
