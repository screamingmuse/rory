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
    end

    def routing_map
      @routes
    end

    def match(mask, options = {})
      options[:to] ||= mask.split('/').first
      regex = /^#{mask.gsub(/:([\w_]+)/, "(?<\\1>\[\^\\\/\]+)")}$/
      controller, action = options[:to].split('#')
      route = {
        :controller => controller,
        :action => action,
        :regex => regex
      }
      route[:methods] = options[:methods] if options[:methods]
      @routes << route
    end
  end
end
