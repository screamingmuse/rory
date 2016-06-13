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

    def self.rack_app(app)
      Proc.new { |env|
        new(Rory::Request.new(env), app).dispatch
      }
    end

    def override_method
      requested_override = request.params['_method']
      return unless requested_override
      if %w(put patch delete).include?(requested_override.downcase)
        requested_override.downcase
      end
    end

    def extension
      File.extname(full_path)[1..-1]
    end

    def json_requested?
      extension == 'json'
    end

    def full_path
      @request.path_info[1..-1] || ''
    end

    def path_without_extension
      full_path.gsub(/(.*)\.#{extension}$/, '\1')
    end

    def method
      override_method || request.request_method.downcase
    end

    def route
      @routing[:route] ||= get_route
    end

    def dispatch
      _controller = controller
      if _controller
        _controller.present
      else
        render_not_found
      end
    end

    def redirect(path = '/')
      unless path =~ /\:\/\//
        path = "#{@request.scheme}://#{@request.host_with_port}#{path}"
      end
      [ 302, {'Content-type' => 'text/html', 'Location'=> path }, ['Redirecting...'] ]
    end

    def render_not_found
      [ 404, {'Content-type' => 'text/html' }, ['Four, oh, four.'] ]
    end

  private

    def controller
      if (klass = controller_class)
        @routing.merge!(:dispatcher => self)
        log_request
        klass.new(request, @routing, @app)
      end
    end

    def log_request
      (@app.controller_logger || Proc.new {}).call(controller: @routing[:route].controller,
                                                   action:     @routing[:route].action,
                                                   params:     @request.params,
                                                   path:       full_path)
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
        route.matches_request?(path_without_extension, method)
      end
      if mapped_route
        @request.params.delete('_method')
        @request.params.merge! mapped_route.path_params(path_without_extension)
      end
      mapped_route
    end

    def all_routes
      @app ? @app.routes : []
    end
  end
end
