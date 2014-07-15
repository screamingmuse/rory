ENV['RORY_STAGE'] ||= ENV['RACK_ENV'] || 'development'

require 'yaml'
require 'sequel'
require 'rory/application'
require 'rory/dispatcher'
require 'rory/route'
require 'rory/support'
require 'rory/controller'
require 'support/env_deprecation'

module Rory
  class << self
    attr_accessor :application

    def root
      app = application
      app && app.root
    end
  end
end
