module Rory
  def self.initialize_request_middleware
    Rory::Application.initializers.add "rory.request_middleware" do |app|
      app.middleware.use Rory::RequestId, :uuid_prefix => app.uuid_prefix
      app.middleware.use Rack::PostBodyContentTypeParser
      app.middleware.use Rack::CommonLogger, app.logger
      app.middleware.use Rory::RequestParameterLogger, app.logger, :filters => app.parameters_to_filter
    end
  end
end
