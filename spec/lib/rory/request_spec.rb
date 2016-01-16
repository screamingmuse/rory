RSpec.describe Rory::Request do
  describe "#uuid" do
    it "returns the value set by env['rory.request_id']" do
      env = { "rory.request_id" => "uuid-from_rory_request" }
      expect(described_class.new(env).uuid).to eq "uuid-from_rory_request"
    end

    context "when no key exists" do
      it "returns nil" do
        expect(described_class.new({}).uuid).to eq nil
      end
    end
  end
end
