class DummyMiddleware
  attr_accessor :prefix

  def initialize(app, *args, &block)
    @app = app
    @args = args
    block.call(self)
  end

  def call(env)
    @app.call("#{prefix} #{@args.first}")
  end
end
