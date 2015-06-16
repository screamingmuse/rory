require_relative 'parameter_filter'

module Rory
  class RequestParameterLogger

    def initialize(app, logger=nil, filters=[:password, :tin, :ssn, :social_security_number, :file_attachment])
      @app = app
      @logger = logger
      @filters = filters
    end

    def call(env)
      @env = env
      @env['rack.input'].rewind
      log_request
      @app.call(@env)
    end

    private

    def log_request
      log_message(request_signature)
      log_message("Parameters: #{filtered_params}")
    end

    def logger
      @logger || @env['rack.errors']
    end

    def log_message(message)
      if logger.respond_to?(:write)
        logger.write(message + "\n")
      else
        logger.info(message)
      end
    end

    def parameter_filter
      Rory::ParameterFilter.new(@filters)
    end

    def filtered_params
      parameter_filter.filter(unfiltered_params)
    end

    def request
      Rack::Request.new(@env)
    end

    def unfiltered_params
      request.params
    end

    def request_signature
      %{Started #{@env['REQUEST_METHOD']} "#{@env['PATH_INFO']}" for #{@env['REMOTE_ADDR']} at #{Time.now}}
    end
  end
end
