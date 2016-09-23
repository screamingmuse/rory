require "rory/support"

module Rory
  module CLI
    module Generators
      class Application < Thor::Group
        include Thor::Actions

        argument :name

        def self.source_root
          File.join(File.dirname(__FILE__), "templates")
        end

        def apply_app_template
          directory "app", tokenized_app_name
        end

      private

        def camelized_app_name
          @camelized_app_name ||= Rory::Support.camelize(name)
        end

        def tokenized_app_name
          @tokenized_app_name ||= Rory::Support.tokenize(name)
        end
      end
    end
  end
end