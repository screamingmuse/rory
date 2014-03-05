require 'rory/path_generation'

module Rory
  class Renderer
    class Context
      include Rory::PathGeneration
      attr_reader :base_path

      def initialize(options = {})
        (options[:locals] || {}).each do |key, value|
          singleton_class.send(:define_method, key) { value }
        end
        @app = options[:app]
        @base_path = options[:base_path]
      end

      def get_binding
        binding
      end

      def render(template_name, opts = {})
        opts = { :layout => false, :app => @app, :base_path => @base_path }.merge(opts)
        renderer = Rory::Renderer.new(template_name, opts)
        renderer.render
      end
    end
  end
end