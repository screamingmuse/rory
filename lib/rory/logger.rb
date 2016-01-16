require "rory/request"
require "logger"

module Rory
  class Logger < ::Logger
    def initialize(io)
      super(io)
      @default_formatter = Formatter.new
    end

    alias_method :write, :info

    private

    def format_message(severity, datetime, progname, msg)
      (@formatter || @default_formatter).call(severity, datetime, progname, msg, request_id)
    end

    def request_id
      Thread.current[:rory_request_id]
    end

    class Formatter < ::Logger::Formatter
      FORMAT = "%s, [%s - %s#%d] %5s -- %s: %s\n"

      def call(severity, time, progname, msg, request_id)
        FORMAT % [severity[0..0], request_id, format_datetime(time), $$, severity, progname, msg2str(msg)]
      end
    end
  end
end
