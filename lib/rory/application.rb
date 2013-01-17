require 'logger'

module Rory
  # Main application superclass.  Applications should subclass this class,
  # but currently no additional configuration is needed - just run '#spin_up'
  # to connect the database so Sequel can do its magic.
  class Application
    attr_reader :db, :db_config

    class << self
      private :new

      def method_missing(*args, &block)
        instance.send(*args, &block)
      end

      def instance
        @instance ||= new
      end
    end

    def routes
      @routes ||= begin
        config_routes_hash = YAML.load_file('config/routes.yml')
        config_routes_hash.map do |mask, target|
          regex = /^#{mask.gsub(/:(\w+)/, "(?<\\1>\\w+)")}$/
          presenter, action = target.split('#')
          {
            :presenter => presenter,
            :action => action,
            :regex => regex
          }
        end
      end
    end

    def spin_up
      connect_db
    end

    def connect_db(environment = ENV['RORY_STAGE'])
      @db_config = YAML.load_file('config/database.yml')
      @db = Sequel.connect(@db_config[environment.to_s])
      @db.loggers << logger
    end

    def call(env)
      Rory::Dispatcher.new(env).dispatch
    end

    def logger
      @logger ||= begin
        file = File.open(File.join('log', "#{ENV['RORY_STAGE']}.log"), 'a')
        Logger.new(file)
      end
    end
  end
end