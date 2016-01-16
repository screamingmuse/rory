require "rory/request"
require "logger"

module Rory
  class Logger < ::Logger
    def initialize(io, options={})
      super(io)
      @default_formatter = Formatter.new
      @tagged            = options.fetch(:tagged, [:request_id])
    end

    def <<(msg)
      super([tagged, msg].reject(&:empty?).join(" "))
    end

    alias_method :write, :<<

    def request_id
      Thread.current.get_inheritable_attribute(:rory_request_id)
    end

    def tagged
      @tagged.map do |key|
        "#{key}=#{quoted_string(public_send(key))}"
      end.join(" ").rstrip
    end

    private

    def quoted_string(str)
      str =~ /\s/ ? %["#{str}"] : str
    end

    def format_message(severity, datetime, progname, msg)
      (@formatter || @default_formatter).call(severity, datetime, progname, msg, tagged)
    end

    class Formatter < ::Logger::Formatter
      FORMAT = "%s, [%s - %s#%d] %5s -- %s: %s\n"

      def call(severity, time, progname, msg, tagged)
        FORMAT % [severity[0..0], tagged, format_datetime(time), $$, severity, progname, msg2str(msg)]
      end
    end
  end
end
