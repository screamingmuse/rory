require "thor"
require_relative "generators/application"

module Rory
  module CLI
    class Generate < Thor
      register Generators::Application, "app", "app [APP_NAME]", "Create a new Rory application"
    end
  end
end
