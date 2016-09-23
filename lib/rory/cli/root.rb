require "thor"
require_relative "generate"

module Rory
  module CLI
    class Root < Thor
      desc "version", "Display version of installed Rory"
      map %w[-v --version] => :version
      def version
        say "rory #{Rory::VERSION}"
      end

      register Generators::Application, "new", "new [APP_NAME]", "Create a new Rory application"
      register Generate, "generate", "generate [COMMAND]", "Delegate to generate command"
    end
  end
end
