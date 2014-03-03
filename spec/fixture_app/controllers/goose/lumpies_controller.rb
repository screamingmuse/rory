module Goose
  class LumpiesController
    def initialize(args, routing, context)
      @args = args
    end

    def present
      @args[:in_scoped_controller] = true
      @args
    end
  end
end
