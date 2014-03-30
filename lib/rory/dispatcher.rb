module Rory
  # The dispatcher takes care of sending an incoming request to the
  # appropriate controller, after examining the routes.
  class Dispatcher
    attr_reader :request
    def initialize(rack_request, app = nil)
      @request = rack_request
      @routing = {}
      @app = app
    end

    def route
      @routing[:route] ||= get_route
    end

    def dispatch
      if controller
        controller.present
      else
        render_not_found
      end
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
        @routing.merge!(:dispatcher => self)
        klass.new(request, @routing, @app)
      end
    end

    def controller_class
      if route
        controller_name = Rory::Support.camelize("#{route.controller}_controller")
        if route.module
          controller_name.prepend "#{Rory::Support.camelize("#{route.module}")}/"
        end
        Rory::Support.constantize(controller_name)
      end
    end

    def get_route
      mapped_route = all_routes.detect do |route|
        route.matches_request?(@request)
      end
      if mapped_route
        @request.params.delete('_method')
        @request.params.merge! mapped_route.path_params(@request)
      end
      mapped_route
    end

    def all_routes
      @app ? @app.routes : []
    end
  end
end
