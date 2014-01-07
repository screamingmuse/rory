class StubController
  def initialize(args, context)
    @args = args
  end

  def present
    @args[:present_called] = true
    @args
  end
end
