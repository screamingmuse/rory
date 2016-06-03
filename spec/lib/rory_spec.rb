describe Rory do
  let!(:new_app) { Class.new(Rory::Application) }

  describe '.application' do
    it 'is by default set to the Rory::Application instance' do
      expect(described_class.application).to eq(new_app.instance)
    end
  end

  describe '.root' do
    it 'returns root of application' do
      expect(described_class.root).to eq(new_app.root)
    end
  end

  describe ".env" do
    it "return the RORY_ENV value" do
      expect(described_class.env).to eq "test"
    end
  end
end
