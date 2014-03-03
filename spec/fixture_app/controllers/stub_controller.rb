class StubController
  def initialize(args, routing, context)
    @args = args
  end

  def present
    @args[:present_called] = true
    @args
  end
end
