require "forwardable"

module Rory
  class Initializers
    class Initializer
      attr_reader :name, :block

      def initialize(name, block)
        @name = name
        @block = block
      end

      def ==(initializer)
        name == initializer.name
      end

      def inspect
       "<Initializer '#{name}'>"
      end

      def call(app)
        block.call(app)
      end
    end

    include Enumerable
    extend Forwardable
    attr_accessor :initializers
    def_delegators :initializers, :each, :clear, :size, :last, :first, :[]

    def initialize
      @initializers = []
      yield(self) if block_given?
    end

    def unshift(name, &block)
      initializers.unshift(build_initializer(name, block))
    end

    def insert(index, name, &block)
      index = assert_index(index, :before)
      initializers.insert(index, build_initializer(name, block))
    end

    alias_method :insert_before, :insert

    def insert_after(index, name, &block)
      index = assert_index(index, :after)
      insert(index + 1, name, &block)
    end

    def delete(target)
      initializers.delete_if { |m| m.name == target }
    end

    def add(name, &block)
      initializers.push(build_initializer(name, block))
    end

    def run(app)
      initializers.map{|i| i.call(app)}
    end

    private

    def assert_index(index, where)
      i     = index.is_a?(Integer) ? index : initializers.index { |m| m.name == index }
      raise "No such initializer to insert #{where}: #{index.inspect}" unless i
      i
    end

    def build_initializer(name, block)
      Initializer.new(name, block).tap{ |i| assert_unique_name(i) }
    end

    def assert_unique_name(i)
      unless (conflict = @initializers.select{|ii| ii == i}).empty?
        raise "Initializer name: '#{i.name}' is already used. #{conflict.first.block}"
      end
    end
  end
end

