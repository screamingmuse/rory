module Rory
  # The dispatcher takes care of sending an incoming request to the
  # appropriate controller, after examining the routes.
  class Dispatcher
    attr_reader :request
    def initialize(rack_request)
      @request = rack_request
      @request[:route] = nil
      @request[:dispatcher] = self
    end

    def get_route(path, method)
      match = nil
      route = Rory::Application.routes.detect do |route_hash|
        match = route_hash[:regex].match(path[1..-1])
        match && (route_hash[:methods].nil? || route_hash[:methods].include?(method.to_sym))
      end
      if route
        symbolized_param_names = match.names.map { |name| name.to_sym }
        @request.params.merge! Hash[symbolized_param_names.zip(match.captures)]
      end
      route
    end

    def dispatch
      @request[:route] = get_route(@request.path, method)

      if @request[:route]
        controller_name = Rory::Support.camelize("#{@request[:route][:controller]}_controller")
        controller_class = Object.const_get(controller_name)
        controller = controller_class.new(@request)
        controller.present
      else
        render_404
      end
    end

    def method
      override_method = @request.params.delete('_method')
      if override_method && ['put', 'patch', 'delete'].include?(override_method.downcase)
        return override_method.downcase
      end
      @request.request_method.downcase
    end

    def redirect(path = '/')
      unless path =~ /\:\/\//
        path = "#{@request.scheme}://#{@request.host_with_port}#{path}"
      end
      return [ 302, {'Content-type' => 'text/html', 'Location'=> path }, ['Redirecting...'] ]
    end

    def render_404
      return [ 404, {'Content-type' => 'text/html' }, ['Four, oh, four.'] ]
    end

    def inspect
      @request.inspect # fixes issue for rspec and pretty_print
    end
  end
end
