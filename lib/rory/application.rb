require 'pathname'
require 'rory/route_mapper'
require 'rory/middleware_stack'
require 'rory/initializers'
require 'rory/sequel_connect'
require 'rory/logging'
require 'rory/default_initializers/request_middleware'

module Rory
  # Main application superclass.  Applications should subclass this class,
  # but currently no additional configuration is needed - just run '#spin_up'
  # to connect the database so Sequel can do its magic.
  class Application
    # Exception raised if no root has been set for this Rory::Application subclass
    class RootNotConfigured < StandardError; end
    include SequelConnect
    include Logging

    attr_reader :db, :db_config
    attr_accessor :config_path
    attr_writer :auto_require_paths

    class << self
      private :new
      attr_reader :root

      def inherited(subclass)
        Rory.application = subclass.instance
      end

      def method_missing(*args, &block)
        instance.send(*args, &block)
      end

      # @return [Rory::Initializers]
      def initializers
        @@initializers ||= Initializers.new
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

      def warmup
        self.warmed_up = true
        run_initializers
      end

      attr_writer :warmed_up
      def warmed_up?
        !!@warmed_up
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

    def set_routes(&block)
      @routes = RouteMapper.set_routes(&block)
    end

    def routes
      load(File.join(config_path, 'routes.rb')) unless @routes
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
      !!Rory::Application.initializers.detect{|init| init.name == "rory.request_logging_middleware" }
    end

    def turn_off_request_logging!
      reset_stack
      Rory::Application.initializers.delete("rory.request_logging_middleware")
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

    def initialize_default_middleware
      Rory::RequestMiddleware.initialize_request_id
      Rory::RequestMiddleware.initialize_logging
    end

    initialize_default_middleware

    def run_initializers
      Rory::Application.initializers.run(self)
    end

    def stack
      @stack ||= Rack::Builder.new.tap { |builder|
        warmup_check
        middleware.each do |m|
          builder.use m.klass, *m.args, &m.block
        end
        builder.run dispatcher
      }
    end

    def call(env)
      stack.call(env)
    end
    private

    def warmup_check
      unless self.class.warmed_up?
        logger.warn("#{self.class.name} was not warmed up before the first request. "\
                    "Call #{self.class.name}.warmup on boot to ensure a quick first response.")
        self.class.warmup
      end
    end
  end
end
