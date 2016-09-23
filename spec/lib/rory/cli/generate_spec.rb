require "rory/cli"

RSpec.describe Rory::CLI::Generate do
  describe "#app" do
    it "delegates to Application" do
      expect(Rory::CLI::Generate.subcommand_classes).
        to eq(Rory::CLI::Generators::Application)
    end
  end
end
