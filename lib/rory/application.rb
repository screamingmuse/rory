require 'pathname'
require 'rory/logger'
require 'rory/request_id'
require 'rory/route_mapper'
require 'rory/middleware_stack'
require 'rory/initializers'
require 'rack/commonlogger'
require 'rory/request_parameter_logger'

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

      # @return [Rory::Initializers]
      def initializers
        @initializers ||= Initializers.new
      end

      def respond_to?(method, private=false)
        return true if instance.respond_to?(method)
        super
      end

      def instance
        @instance ||= new
      end

      def root=(root_path)
        $:.unshift @root = Pathname.new(root_path).realpath
      end

      def initializer_default_middleware
        Rory::Application.initializers.add "rory.request_middleware" do |app|
          app.request_middleware
        end
      end
    end

    initializer_default_middleware

    def auto_require_paths
      @auto_require_paths ||= %w(config/initializers models controllers helpers)
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
      middleware.use *args, &block
    end

    def middleware
      @middleware ||= MiddlewareStack.new
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

    def uuid_prefix
      Support.tokenize(self.class.name.gsub("::Application", ""))
    end

    def request_middleware
      return unless request_logging_on?
      use_middleware Rory::RequestId, :uuid_prefix => uuid_prefix
      use_middleware Rack::PostBodyContentTypeParser
      use_middleware Rack::CommonLogger, logger
      use_middleware Rory::RequestParameterLogger, logger, :filters => parameters_to_filter
    end

    def run_initializers
      Rory::Application.initializers.run(self)
    end

    def stack
      @stack ||= Rack::Builder.new.tap { |builder|
        run_initializers
        middleware.each do |m|
          builder.use m.klass, *m.args, &m.block
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
