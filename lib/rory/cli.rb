require "thor"
require_relative "cli/root"

module Rory
  module CLI
    def self.start
      Root.start
    end
  end
end
