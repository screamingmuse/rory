module Rory
  # Makes a unique request id available to the rory.request_id env variable (which is then accessible through
  # Rory::Request#uuid) and sends the same id to the client via the X-Request-Id header.
  #
  # The unique request id is either based off the X-Request-Id header in the request, which would typically be generated
  # by a firewall, load balancer, or the web server, or, if this header is not available, a random uuid. If the
  # header is accepted from the outside world, we sanitize it to a max of 255 chars and alphanumeric and dashes only.
  #
  # The unique request id can be used to trace a request end-to-end and would typically end up being part of log files
  # from multiple pieces of the stack.
  class RequestId
    def initialize(app, options={})
      @app          = app
      @uuid_creator = options.fetch(:uuid_creator, SecureRandom)
      @uuid_prefix  = options[:uuid_prefix]
    end

    def call(env)
      env["rory.request_id"] = external_request_id(env) || internal_request_id
      Thread.current.set_inheritable_attribute(:rory_request_id, env["rory.request_id"])
      @app.call(env).tap { |_status, headers, _body| headers["X-Request-Id"] = env["rory.request_id"] }
    end

    private

    def external_request_id(env)
      if (request_id = env["HTTP_X_REQUEST_ID"])
        request_id.gsub(/[^\w\-]/, "")[0..254]
      end
    end

    def internal_request_id
      "#{uuid_prefix}#{@uuid_creator.uuid}"
    end

    def uuid_prefix
      @uuid_prefix ? "#{@uuid_prefix}-" : ""
    end
  end
end
