require 'erb'

module Rory
  class Presenter
    def initialize(request)
      @request = request
      @route = request[:route]
      @params = @route[:params]
    end

    def route_template
      "#{@route[:presenter]}/#{@route[:action]}"
    end

    def render(template)
      file = File.expand_path("views/#{template}.html.erb", Rory.root)
      @body = ERB.new(File.read(file)).result(binding)
    end

    def redirect(path)
      @response = @request[:dispatcher].redirect(path)
    end

    def present
      # if a method exists on the presenter for the requested action, call it.
      self.send(@route[:action]) if self.respond_to?(@route[:action])

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