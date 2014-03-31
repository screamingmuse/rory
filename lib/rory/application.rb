require 'pathname'
require 'logger'
require 'rory/route_mapper'

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

      def inherited(base)
        super
        Rory.application = base.instance
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
      @config_path ||= begin
        root_path.join('config')
      end
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

    def connect_db(environment = ENV['RORY_STAGE'])
      @db_config = load_config_data(:database)
      @db = Sequel.connect(@db_config[environment.to_s])
      @db.loggers << logger
    end

    def use_middleware(*args, &block)
      middleware << [args, block]
    end

    def middleware
      @middleware ||= []
    end

    def dispatcher
      Rory::Dispatcher.rack_app(self)
    end

    def stack
      builder = Rack::Builder.new
      middleware.each do |args, block|
        builder.use *args, &block
      end
      builder.run dispatcher
      builder
    end

    def call(env)
      stack.call(env)
    end

    def logger
      @logger ||= begin
        Dir.mkdir('log') unless File.exists?('log')
        file = File.open(File.join('log', "#{ENV['RORY_STAGE']}.log"), 'a')
        Logger.new(file)
      end
    end
  end
end
