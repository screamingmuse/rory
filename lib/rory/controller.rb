require 'rory/renderer'
require 'rory/path_generation'

module Rory
  # Interface for Controller class.  Subclass this to create controllers
  # with actions that will be called by the Dispatcher when a route matches.
  class Controller
    include PathGeneration

    attr_accessor :locals

    class << self
      def before_actions
        @before_actions ||= []
      end

      def after_actions
        @after_actions ||= []
      end

      # Register a method to run before the action method.
      def before_action(method_name)
        before_actions << method_name
      end

      # Register a method to run after the action method.
      def after_action(method_name)
        after_actions << method_name
      end
    end

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
      "#{@route.controller}/#{@route.action}"
    end

    def layout
      nil
    end

    def base_path
      @request.script_name
    end

    def default_renderer_options
      {
        :layout => layout,
        :locals => locals,
        :app => @app,
        :base_path => base_path
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
      # Call all before and after filters, and if a method exists on the
      # controller for the requested action, call it in between.
      call_filtered_action(@route.action)

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

  private

    def call_filter_set(which_set, opts = {})
      opts[:break_if_response] ||= true
      filters = self.class.send(which_set)
      filters.each do |filter|
        self.send(filter)
        break if @response && opts[:break_if_response]
      end
    end

    def call_filtered_action(action)
      call_filter_set(:before_actions)
      unless @response
        self.send(action) if self.respond_to?(action)
        call_filter_set(:after_actions, :break_if_response => false)
      end
    end
  end
end
