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
    end

    # @!macro add
    #   @param [String] name the reference name of the initializer
    #   @yield [app] block the code to be run for the initializer

    ##
    # @!macro add
    def unshift(name, &block)
      initializers.unshift(build_initializer(name, block))
    end

    # @!macro insert
    #   @param [String, Integer] index either an index or a string reference
    #   @param [String] name the reference name of the initializer
    #   @yield [app] block the code to be run for the initializer
    #   @raise [NoInitializerFound] when reference name is not found

    # @!macro insert_optional
    #   @param [String, Integer] index either an index or a string reference
    #   @param [String] name the reference name of the initializer
    #   @yield [app] block the code to be run for the initializer
    #   @return [OrAdd, #or_add] Try to insert after but if that initializer reference cannot be found add on to the end.
    #   @example
    #     @method "init_name", "new_init" do |app|
    #       ...
    #     end #=> if "init_name" is not found raises NoInitializerFound
    #
    #     @method.or_add "init_name", "new_init" do |app|
    #       ...
    #     end #=> if "init_name" is not found add to the end

    ##
    # Insert before an already added initializer
    # @!macro insert_optional
    def insert(*args, &block)
      if args.empty?
        OrAdd.new(method(:_insert), method(:add))
      else
        _insert(*args, &block)
      end
    end

    alias_method :insert_before, :insert
    # Insert after an already added initializer
    # @!macro insert_optional
    def insert_after(*args, &block)
      if args.empty?
        OrAdd.new(method(:_insert_after), method(:add))
      else
        _insert_after(*args, &block)
      end
    end

    class OrAdd
      def initialize(insert, add)
        @insert = insert
        @add    = add
      end

      # @!macro insert
      def or_add(index, name, &block)
        @insert.call(index, name, &block)
      rescue NoInitializerFound
        @add.call(name, &block)
      end
    end

    # @param [String] name the reference name of the initializer
    def delete(name)
      initializers.delete_if { |m| m.name == name }
    end

    # @!macro add
    def add(name, &block)
      initializers.push(build_initializer(name, block))
    end

    def run(app)
      initializers.map{|i| i.call(app)}
    end

    private

    def _insert_after(index, name, &block)
      index = assert_index(index, :after, name)
      insert(index + 1, name, &block)
    end

    def _insert(index, name, &block)
      index = assert_index(index, :before, name)
      initializers.insert(index, build_initializer(name, block))
    end

    NoInitializerFound = Class.new(StandardError)

    def assert_index(index, where, for_init)
      i     = index.is_a?(Integer) ? index : initializers.index { |m| m.name == index }
      raise NoInitializerFound, "No such initializer to insert #{where}: #{index.inspect} for #{for_init.inspect}" unless i
      i
    end

    def build_initializer(name, block)
      Initializer.new(name, block).tap{ |i| assert_unique_name(i) }
    end

    InitializerNameNotUnique = Class.new(StandardError)
    def assert_unique_name(i)
      unless (conflict = @initializers.select{|ii| ii == i}).empty?
        raise InitializerNameNotUnique, "Initializer name: '#{i.name}' is already used. #{conflict.first.block}"
      end
    end
  end
end

