require "rory/cli"

RSpec.describe Rory::CLI::Root do
  describe "#version" do
    it "says the current Rory VERSION constant" do
      expect(subject).to receive(:say).with("rory #{Rory::VERSION}")
      subject.version
    end
  end

  describe "#generate" do
    it "delegates to generate" do
      expect(Rory::CLI::Root.subcommand_classes["generate"]).
        to eq(Rory::CLI::Generate)
    end
  end

  describe "#new" do
    it "starts Generators::Application" do
      subject.new
    end
  end
end
