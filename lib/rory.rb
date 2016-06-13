ENV['RORY_ENV'] ||= ENV['RACK_ENV'] || 'development'

require 'yaml'
require 'sequel'
require 'thread/inheritable_attributes'
require 'rack/contrib'
require 'rory/application'
require 'rory/dispatcher'
require 'rory/route'
require 'rory/support'
require 'rory/controller'
require 'rory/version'

module Rory
  class << self
    attr_accessor :application

    def root
      app = application
      app && app.root
    end

    def env
      ENV["RORY_ENV"]
    end
  end
end
