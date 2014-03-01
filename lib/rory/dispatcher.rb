module Rory
  # The dispatcher takes care of sending an incoming request to the
  # appropriate controller, after examining the routes.
  class Dispatcher
    attr_reader :request
    def initialize(rack_request, context = nil)
      @request = rack_request
      @context = context
    end

    def route
      @request[:route] ||= get_route
    end

    def dispatch
      if controller
        controller.present
      else
        render_not_found
      end
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

  private

    def controller
      if klass = controller_class
        request_for_delivery = @request.dup
        request_for_delivery[:dispatcher] = self
        klass.new(request_for_delivery, @context)
      end
    end

    def controller_class
      if route
        controller_name = Rory::Support.camelize("#{route[:controller]}_controller")
        if route[:module]
          controller_name.prepend "#{Rory::Support.camelize("#{route[:module]}")}/"
        end
        Rory::Support.constantize(controller_name)
      end
    end

    def get_route
      match = nil
      mapped_route = route_map.detect do |route_hash|
        path_name = @request.path_info[1..-1] || ''
        match = route_hash[:regex].match(path_name)
        methods = route_hash[:methods] || []
        match && (methods.empty? || methods.include?(method.to_sym))
      end
      if mapped_route
        symbolized_param_names = match.names.map { |name| name.to_sym }
        @request.params.merge! Hash[symbolized_param_names.zip(match.captures)]
      end
      mapped_route
    end

    def route_map
      @context ? @context.routes : []
    end
  end
end
