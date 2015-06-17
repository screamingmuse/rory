require 'pathname'
require 'logger'
require 'rory/route_mapper'
require 'rack/commonlogger'
require_relative 'request_parameter_logger'


module Rory
  # Main application superclass.  Applications should subclass this class,
  # but currently no additional configuration is needed - just run '#spin_up'
  # to connect the database so Sequel can do its magic.
  class Application
    # Exception raised if no root has been set for this Rory::Application subclass
    class RootNotConfigured < StandardError; end

    attr_reader :db, :db_config
    attr_accessor :config_path

    class << self
      private :new
      attr_reader :root

      def inherited(subclass)
        super
        Rory.application = subclass.instance
      end

      def method_missing(*args, &block)
        instance.send(*args, &block)
      end

      def respond_to?(method)
        return true if instance.respond_to?(method)
        super
      end

      def instance
        @instance ||= new
      end

      def root=(root_path)
        @root = Pathname.new(root_path).expand_path
      end
    end

    def auto_require_paths
      @auto_require_paths ||= %w(models controllers helpers)
    end

    def require_all_files
      auto_require_paths.each do |path|
        Rory::Support.require_all_files_in_directory root_path.join(path)
      end
    end

    def root
      self.class.root
    end

    def root_path
      root || raise(RootNotConfigured, "#{self.class.name} has no root configured")
    end

    def config_path
      @config_path ||= root_path.join('config')
    end

    def log_path
      @log_path ||= root_path.join('log')
    end

    def set_routes(&block)
      @routes = RouteMapper.set_routes(&block)
    end

    def routes
      unless @routes
        load(File.join(config_path, 'routes.rb'))
      end
      @routes
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

    def connect_db(environment = ENV['RORY_ENV'])
      @db_config = load_config_data(:database)
      @db = Sequel.connect(@db_config[environment.to_s])
      @db.loggers << logger
    end

    def use_middleware(*args, &block)
      @stack = nil
      middleware << [args, block]
    end

    def middleware
      @middleware ||= []
    end

    def dispatcher
      Rory::Dispatcher.rack_app(self)
    end

    def request_logging_on?
      @request_logging != false
    end

    def turn_off_request_logging!
      reset_stack
      @request_logging = false
    end

    def parameters_to_filter
      @parameters_to_filter || [:password]
    end

    def filter_parameters(*params)
      reset_stack
      @parameters_to_filter = params
    end

    def reset_stack
      @stack = nil
    end

    def use_default_middleware
      if request_logging_on?
        use_middleware Rack::PostBodyContentTypeParser
        use_middleware Rack::CommonLogger, logger
        use_middleware Rory::RequestParameterLogger, logger, filters: parameters_to_filter
      end
    end

    def stack
      @stack ||= Rack::Builder.new.tap { |builder|
        use_default_middleware
        middleware.each do |args, block|
          builder.use *args, &block
        end
        builder.run dispatcher
      }
    end

    def call(env)
      stack.call(env)
    end

    def log_file
      Dir.mkdir(log_path) unless File.exists?(log_path)
      File.open(log_path.join("#{ENV['RORY_ENV']}.log"), 'a').tap { |file| file.sync = true }
    end

    def logger
      @logger ||= Logger.new(log_file)
    end
  end
end
