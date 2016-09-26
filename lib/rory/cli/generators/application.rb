require "rory/support"

module Rory
  module CLI
    module Generators
      class Application < Thor::Group
        include Thor::Actions

        argument :name
        class_option :rspec, type: :boolean

        def self.source_root
          File.join(File.dirname(__FILE__), "templates")
        end

        def apply_app_template
          directory "app", tokenized_app_name, exclude_pattern: exclude_pattern
        end

      private

        def exclude_pattern
          patterns = [].tap { |patterns|
            unless options[:rspec]
              patterns << "spec\/spec_helper\.rb"
              patterns << ".rspec"
            end
          }
          patterns.empty? ? nil : /#{patterns.join("|")}/
        end

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