require 'rack/commonlogger'
require 'rory/request_parameter_logger'
require 'rory/request_id'

module Rory
  module RequestMiddleware
    class << self
      def initialize_logging
        Rory::Application.initializers.add "rory.request_logging_middleware" do |app|
          app.use_middleware Rack::PostBodyContentTypeParser
          app.use_middleware Rack::CommonLogger, app.logger
          app.use_middleware Rory::RequestParameterLogger, app.logger, :filters => app.parameters_to_filter
        end
      end

      def initialize_request_id
        Rory::Application.initializers.add "rory.request_id_middleware" do |app|
          app.use_middleware Rory::RequestId, :uuid_prefix => app.uuid_prefix
        end
      end
    end
  end
end
