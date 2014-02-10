module Rory
  # Route mapper, used to convert the entries in 'config/routes.rb' into
  # a routing table for use by the dispatcher.
  class RouteMapper
    class << self
      def set_routes(&block)
        mapper = new
        mapper.instance_exec(&block)
        mapper.routing_map
      end
    end

    def initialize
      @routes = []
      @scope_options = {}
    end

    def routing_map
      @routes
    end

    def scope(options = {}, &block)
      previous_options, @scope_options =
        @scope_options, @scope_options.merge(options)
      yield
      @scope_options = previous_options
    end

    def match(mask, options = {})
      options.merge!(@scope_options)
      options[:to] ||= mask.split('/').first
      mask.gsub!(/^\//, '')
      regex = /^#{mask.gsub(/:([\w_]+)/, "(?<\\1>\[\^\\\/\]+)")}$/
      controller, action = options[:to].split('#')
      route = {
        :controller => controller,
        :action => action,
        :regex => regex
      }
      route[:module] = options[:module] if options[:module]
      route[:methods] = options[:methods] if options[:methods]
      @routes << route
    end
  end
end
