module Rory
  class Controller
    class RequestLogger
      def initialize(logger:)
        @logger = logger
      end

      def call(controller:, action:, params:, path:)
        logger.info("request -- #{{path: path, action: action, controller: controller, params: params }}")
      end

      private

      attr_reader :logger
    end
  end
end
