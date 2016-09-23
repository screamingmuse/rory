require "rory/cli"

RSpec.describe Rory::CLI do
  describe "#start" do
    it "delegates to Root class" do
      allow(Rory::CLI::Root).to receive(:start).and_return(:started)
      expect(described_class.start).to eq :started
    end
  end
end
