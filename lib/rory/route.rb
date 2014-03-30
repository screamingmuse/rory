module Rory
  class Route
    attr_reader :controller, :action, :mask

    def initialize(mask, options = {})
      @mask = mask.gsub(/^\//, '')
      @options = options
      @controller, @action = options[:to].split('#')
    end

    def name
      "#{controller}_#{action}"
    end

    def ==(other)
      to_h == other.to_h
    end

    def regex
      /^#{@mask.gsub(/:([\w_]+)/, "(?<\\1>\[\^\\\/\]+)")}$/
    end

    def module
      @options[:module]
    end

    def methods
      @options[:methods] || []
    end

    def matches_request?(request)
      @match = regex.match(request.path_info[1..-1] || '')
      @match &&
        (methods.empty? ||
          methods.include?(method_from_request(request).to_sym))
    end

    def path_params(request)
      @match ||= regex.match(request.path_info[1..-1] || '')
      symbolized_param_names = @match.names.map { |name| name.to_sym }
      Hash[symbolized_param_names.zip(@match.captures)]
    end

    def to_h
      {
        :mask => @mask,
        :controller => @controller,
        :action => @action,
        :module => @module,
        :methods => @methods
      }
    end

  private

    def method_from_request(request)
      override_method = request.params['_method']
      method = if override_method && ['put', 'patch', 'delete'].include?(override_method.downcase)
        override_method
      else
        request.request_method
      end
      method.downcase
    end
  end
end