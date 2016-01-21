require "thread"

class Thread
  alias_method :_initialize, :initialize

  def initialize(*args, &block)
    _initialize(*args, &block).tap do |inst|
      inst[:inheritable_attributes] = Thread.current[:inheritable_attributes]
    end
  end

  def inheritable_attributes
    self[:inheritable_attributes] ||= {}
  end
end
