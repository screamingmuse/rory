module Rory
  def self.initialize_request_middleware
    Rory::Application.initializers.add "rory.request_middleware" do |app|
      app.use_middleware Rory::RequestId, :uuid_prefix => app.uuid_prefix
      app.use_middleware Rack::PostBodyContentTypeParser
      app.use_middleware Rack::CommonLogger, app.logger
      app.use_middleware Rory::RequestParameterLogger, app.logger, :filters => app.parameters_to_filter
    end
  end
end
