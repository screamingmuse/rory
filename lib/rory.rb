ENV['RORY_STAGE'] ||= ENV['RACK_ENV'] || 'development'

require 'yaml'
require 'sequel'
require 'rory/application'
require 'rory/dispatcher'
require 'rory/support'
require 'rory/presenter'

module Rory
  class << self
    attr_accessor :root

    def autoload_all_files
      (
       Dir[File.join(@root, 'models', '*.rb')] +
       Dir[File.join(@root, 'presenters', '*.rb')] +
       Dir[File.join(@root, 'helpers', '*.rb')]
      ).each do |path|
        path = File.expand_path(path)
        name = File.basename(path).sub(/(.*)\.rb$/, '\1')
        name = Rory::Support.camelize(name)
        Object.autoload name.to_sym, path
      end
    end
  end
end