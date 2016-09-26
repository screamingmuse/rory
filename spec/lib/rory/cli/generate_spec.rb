require "rory/cli"

RSpec.describe Rory::CLI::Generate do
  describe "#app" do
    it "starts Generators::Application" do
      proxy = instance_double(Rory::CLI::Generators::Application)
      allow(proxy).to receive(:parent_options=).with({})
      allow(Rory::CLI::Generators::Application).to receive(:new).
        with(["frog"], any_args).
        and_return(proxy)

      expect(proxy).to receive(:invoke_all)
      subject.app("frog")
    end
  end
end
