module Rory
  # The dispatcher takes care of sending an incoming request to the
  # appropriate controller, after examining the routes.
  class Dispatcher
    attr_reader :request
    def initialize(rack_request, context = nil)
      @request = rack_request
      @request[:route] ||= nil
      @request[:dispatcher] = self
      @context = context
    end

    def route_map
      @context ? @context.routes : []
    end

    def get_route
      match = nil
      route = route_map.detect do |route_hash|
        path_name = @request.path_info[1..-1] || ''
        match = route_hash[:regex].match(path_name)
        methods = route_hash[:methods] || []
        match && (methods.empty? || methods.include?(method.to_sym))
      end
      if route
        symbolized_param_names = match.names.map { |name| name.to_sym }
        @request.params.merge! Hash[symbolized_param_names.zip(match.captures)]
      end
      route
    end

    def dispatch
      route = set_route_if_empty

      if route
        controller_name = Rory::Support.camelize("#{route[:controller]}_controller")
        controller_class = Object.const_get(controller_name)
        controller_class.new(@request, @context).present
      else
        render_not_found
      end
    end

    def set_route_if_empty
      @request[:route] ||= get_route
    end

    def method
      override_method = @request.params.delete('_method')
      method = if override_method && ['put', 'patch', 'delete'].include?(override_method.downcase)
        override_method
      else
        @request.request_method
      end
      method.downcase
    end

    def redirect(path = '/')
      unless path =~ /\:\/\//
        path = "#{@request.scheme}://#{@request.host_with_port}#{path}"
      end
      return [ 302, {'Content-type' => 'text/html', 'Location'=> path }, ['Redirecting...'] ]
    end

    def render_not_found
      return [ 404, {'Content-type' => 'text/html' }, ['Four, oh, four.'] ]
    end

    def inspect
      @request.inspect # fixes issue for rspec and pretty_print
    end
  end
end
