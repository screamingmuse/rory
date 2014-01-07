require 'erb'

module Rory
  # Interface for Controller class.  Subclass this to create controllers
  # with actions that will be called by the Dispatcher when a route matches.
  class Controller
    def initialize(request, context = nil)
      @request = request
      @route = request[:route]
      @params = request.params
      @context = context
    end

    def route_template
      "#{@route[:controller]}/#{@route[:action]}"
    end

    def layout
      nil
    end

    def render(template, opts = {})
      opts = { :layout => layout }.merge(opts)
      file = view_path(template)
      output = ERB.new(File.read(file)).result(binding)
      if layout = opts[:layout]
        output = render(File.join('layouts', layout.to_s), { :layout => false }) { output }
      end
      @body = output
    end

    def view_path(template)
      root = @context ? @context.root : Rory.root
      File.expand_path(File.join('views', "#{template}.html.erb"), root)
    end

    def redirect(path)
      @response = @request[:dispatcher].redirect(path)
    end

    def render_not_found
      @response = @request[:dispatcher].render_not_found
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
