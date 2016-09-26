module GenerationHelpers
  def sandbox_directory
    Pathname.new(
      File.join(File.dirname(__FILE__), "..", "sandbox")
    )
  end

  def capture_output
    begin
      $stdout = StringIO.new
      yield
      result = $stdout.string
    ensure
      $stdout = STDOUT
    end

    result
  end
end