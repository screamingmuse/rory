ENV['RORY_STAGE'] ||= ENV['RACK_ENV'] || 'development'

require 'yaml'
require 'sequel'
require 'rory/application'
require 'rory/dispatcher'
require 'rory/support'
require 'rory/controller'

module Rory
  extend self

  attr_accessor :root

  def autoload_paths
    @autoload_paths ||= %w(models controllers helpers)
  end

  def autoload_all_files
    autoload_paths.each do |path|
      Dir[File.join(@root, path, '*.rb')].each do |file|
        autoload_file file
      end
    end
  end

  def extract_class_name_from_path(path)
    name = File.basename(path).sub(/(.*)\.rb$/, '\1')
    name = Rory::Support.camelize(name)
  end

  def autoload_file(path)
    path = File.expand_path(path)
    name = extract_class_name_from_path(path)
    Object.autoload name.to_sym, path
  end
end
