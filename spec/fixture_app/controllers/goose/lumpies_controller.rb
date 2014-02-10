module Goose
  class LumpiesController
    def initialize(args, context)
      @args = args
    end

    def present
      @args[:in_scoped_controller] = true
      @args
    end
  end
end
