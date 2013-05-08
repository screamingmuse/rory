module Rory
  # The dispatcher takes care of sending an incoming request to the
  # appropriate presenter, after examining the routes.
  class Dispatcher
    attr_reader :request
    def initialize(env)
      @request = env.dup
      @request[:path] = env['PATH_INFO'][1..-1] if env['PATH_INFO']
      @request[:route] = nil
      @request[:params] = parse_query(env['QUERY_STRING'])
      @request[:dispatcher] = self
    end

    def parse_query(query_string)
      Rack::Utils.parse_query(query_string.to_s)
    end

    def get_route(path)
      match = nil
      route = Rory::Application.routes.detect do |route_hash|
        match = route_hash[:regex].match(path)
      end
      if route
        symbolized_param_names = match.names.map { |name| name.to_sym }
        @request[:params].merge! Hash[symbolized_param_names.zip(match.captures)]
      end
      route
    end

    def dispatch
      @request[:route] = get_route(@request[:path])

      if @request[:route]
        presenter_name = Rory::Support.camelize("#{@request[:route][:presenter]}_presenter")
        presenter_class = Object.const_get(presenter_name)
        presenter = presenter_class.new(@request)
        presenter.present
      else
        render_404
      end
    end

    def redirect(path = '/')
      unless path =~ /\:\/\//
        path = "#{@request['rack.url_scheme']}://#{@request['HTTP_HOST']}#{path}"
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
