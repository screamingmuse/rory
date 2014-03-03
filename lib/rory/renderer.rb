require 'erb'
require_relative 'renderer/context'

module Rory
  class Renderer
    def initialize(template_name, options = {})
      @template_name = template_name
      @options = options
      @app = options[:app]
    end

    def render(&block)
      erb = ERB.new(view_template)
      output = erb.result(view_binding(&block))
      if layout_path
        layout_renderer = self.class.new(layout_path, @options.merge(:layout => false))
        output = layout_renderer.render { output }
      end
      output
    end

    def view_binding
      render_context = Context.new(@options)
      render_context.get_binding { |*args|
        yield(args) if block_given?
      }
    end

    def view_template
      File.read(view_path)
    end

    def layout_path
      return nil unless @options[:layout]
      File.join('layouts', @options[:layout].to_s)
    end

    def view_path
      root = @app ? @app.root : Rory.root
      File.expand_path(File.join('views', "#{@template_name}.html.erb"), root)
    end
  end
end