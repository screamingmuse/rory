ENV['RORY_ENV'] ||= ENV['RORY_STAGE'] || ENV['RACK_ENV'] || 'development'

if ENV['RORY_STAGE']
  puts "\n\tWARNING: use of 'RORY_STAGE' is ignored. Use 'RORY_ENV' instead.\n\n"
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
