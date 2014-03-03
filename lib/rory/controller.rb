require_relative 'renderer'

module Rory
  # Interface for Controller class.  Subclass this to create controllers
  # with actions that will be called by the Dispatcher when a route matches.
  class Controller
    attr_accessor :locals

    def initialize(request, routing, app = nil)
      @request = request
      @dispatcher = routing[:dispatcher]
      @route = routing[:route]
      @params = request.params
      @app = app
      @locals = {}
    end

    def expose(hsh)
      locals.merge!(hsh)
    end

    def params
      @converted_params ||= @params.inject({}) { |memo, (key, value)|
        memo[key.to_sym] = memo[key.to_s] = value
        memo
      }
    end

    def route_template
      "#{@route[:controller]}/#{@route[:action]}"
    end

    def layout
      nil
    end

    def default_renderer_options
      {
        :layout => layout,
        :locals => locals,
        :app => @app,
        :base_url => @request.script_name
      }
    end

    def render(template_name, opts = {})
      opts = default_renderer_options.merge(opts)
      renderer = Rory::Renderer.new(template_name, opts)
      @body = renderer.render
    end

    def redirect(path)
      @response = @dispatcher.redirect(path)
    end

    def render_not_found
      @response = @dispatcher.render_not_found
    end

    def present
      # if a method exists on the controller for the requested action, call it.
      action = @route[:action]
      self.send(action) if self.respond_to?(action)

      if @response
        # that method may have resulted in a response already being generated
        # (such as a redirect, or 404, or other non-HTML response).  if so,
        # just return that response.
        @response
      else
        # even if there wasn't a full response generated, we might already have
        # a @body, if render was explicitly called to render an alternate
        # template, or if @body was explicitly assigned for some other reason.
        # don't render the default template, in that case.
        @body ||= render(route_template)
        [200, {'Content-type' => 'text/html', 'charset' => 'UTF-8'}, [@body]]
      end
    end
  end
end
