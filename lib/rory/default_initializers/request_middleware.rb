require 'rack/commonlogger'
require 'rory/request_parameter_logger'
require 'rory/request_id'
require 'rory/controller/request_logger'

module Rory
  module RequestMiddleware
    class << self
      def initialize_post_body_type_parser
        Rory::Application.initializers.add "rory.post_body_type_parser" do |app|
          app.use_middleware Rack::PostBodyContentTypeParser
        end
      end

      def initialize_controller_logger
        Rory::Application.initializers.add "rory.controller_logger" do |app|
          app.controller_logger = Controller::RequestLogger.new(logger: app.logger)
        end
      end

      def initialize_logging
        Rory::Application.initializers.add "rory.request_logging_middleware" do |app|
          app.use_middleware Rack::CommonLogger, app.logger
          app.use_middleware Rory::RequestParameterLogger, app.logger, :filters => app.parameters_to_filter
        end
      end

      def initialize_request_id
        Rory::Application.initializers.add "rory.request_id_middleware" do |app|
          app.use_middleware Rory::RequestId, :uuid_prefix => app.uuid_prefix
        end
      end

      def initialize_default_middleware
        initialize_post_body_type_parser
        initialize_controller_logger
        initialize_logging
        initialize_request_id
      end
    end
  end
end
