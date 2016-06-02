require "forwardable"

module Rory
  class MiddlewareStack
    class Middleware
      attr_reader :args, :block, :klass

      def initialize(klass, args, block)
        @klass = klass
        @args  = args
        @block = block
      end

      def name;
        klass.name;
      end

      def ==(middleware)
        case middleware
        when Middleware
          klass == middleware.klass
        when Class
          klass == middleware
        end
      end

      def inspect
        if klass.is_a?(Class)
          klass.to_s
        else
          klass.class.to_s
        end
      end

      def build(app)
        klass.new(app, *args, &block)
      end
    end

    include Enumerable
    extend Forwardable
    attr_accessor :middlewares
    def_delegators :middlewares, :each, :clear, :size, :last, :first, :[]

    def initialize
      @middlewares = []
      yield(self) if block_given?
    end

    def unshift(klass, *args, &block)
      middlewares.unshift(build_middleware(klass, args, block))
    end

    def insert(*args, &block)
      if args.empty?
        OrAdd.new(method(:_insert), method(:use))
      else
        _insert(*args, &block)
      end
    end

    alias_method :insert_before, :insert

    def insert_after(*args, &block)
      if args.empty?
        OrAdd.new(method(:_insert_after), method(:use))
      else
        _insert_after(*args, &block)
      end
    end

    class OrAdd
      def initialize(insert, use)
        @insert = insert
        @use    = use
      end

      def or_add(*args, &block)
        @insert.call(*args, &block)
      rescue MiddlewareNotFound
        @use.call(*args, &block)
      end
    end

    def delete(target)
      middlewares.delete_if { |m| m.klass == target }
    end

    def use(klass, *args, &block)
      middlewares.push(build_middleware(klass, args.compact, block))
    end

    private

    def _insert(index, klass, *args, &block)
      index = assert_index(index, :before, klass)
      middlewares.insert(index, build_middleware(klass, args, block))
    end

    def _insert_after(index, klass, *args, &block)
      index = assert_index(index, :after, klass)
      insert(index + 1, klass, *args, &block)
    end

    MiddlewareNotFound = Class.new(StandardError)
    def assert_index(index, where, for_middleware)
      i     = index.is_a?(Integer) ? index : middlewares.index { |m| m.klass == index }
      raise MiddlewareNotFound, "No such middleware to insert #{where}: #{index.inspect} for #{for_middleware.name}" unless i
      i
    end

    def build_middleware(klass, args, block)
      Middleware.new(klass, args, block)
    end
  end
end
