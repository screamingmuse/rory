module Rory
  class Renderer
    class Context
      attr_reader :base_url

      def initialize(options = {})
        (options[:locals] || {}).each do |key, value|
          singleton_class.send(:define_method, key) { value }
        end
        @app = options[:app]
        @base_url = options[:base_url]
      end

      def get_binding
        binding
      end

      def render(template_name, opts = {})
        opts = { :layout => false, :app => @app }.merge(opts)
        renderer = Rory::Renderer.new(template_name, opts)
        renderer.render
      end
    end
  end
end