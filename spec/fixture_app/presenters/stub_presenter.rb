class StubPresenter
  def initialize(args)
    @args = args
  end

  def present
    @args[:present_called] = true
    @args
  end
end
