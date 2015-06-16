ENV['RORY_ENV'] ||= ENV['RACK_ENV'] || 'development'

require 'yaml'
require 'sequel'
require 'rack/contrib'
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
