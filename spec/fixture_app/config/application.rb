module Fixture
  class Application < Rory::Application
    turn_off_request_logging!
    filter_parameters :orcas, :noodles
  end
end
