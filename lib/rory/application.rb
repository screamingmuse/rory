require 'logger'


module Rory
  # Main application superclass.  Applications should subclass this class,
  # but currently no additional configuration is needed - just run '#spin_up'
  # to connect the database so Sequel can do its magic.
  class Application
    attr_reader :db, :db_config
    attr_accessor :config_path

    class << self
      private :new

      def method_missing(*args, &block)
        instance.send(*args, &block)
      end

      def instance
        @instance ||= new
      end
    end

    def initialize
      @config_path = File.join(Rory.root, 'config')
    end

    def routes
      @routes ||= begin
        config_routes_hash = load_config_data(:routes)
        config_routes_hash.map do |mask, target|
          regex = /^#{mask.gsub(/:([\w_]+)/, "(?<\\1>\[\^\\\/\]+)")}$/
          presenter, action = target.split('#')
          {
            :presenter => presenter,
            :action => action,
            :regex => regex
          }
        end
      end
    end

    def configure
      yield self
    end

    def spin_up
      connect_db
    end

    def load_config_data(config_type)
      YAML.load_file(
        File.expand_path(File.join(config_path, "#{config_type}.yml"))
      )
    end

    def connection
      @db
    end

    def connect_db(environment = ENV['RORY_STAGE'])
      @db_config = load_config_data(:database)
      @db = Sequel.connect(@db_config[environment.to_s])
      @db.loggers << logger
    end

    def call(env)
      Rory::Dispatcher.new(Rack::Request.new(env)).dispatch
    end

    def logger
      @logger ||= begin
        file = File.open(File.join('log', "#{ENV['RORY_STAGE']}.log"), 'a')
        Logger.new(file)
      end
    end
  end
end
