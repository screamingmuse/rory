describe Rory do
  describe '.application' do
    it 'is by default set to the Rory::Application instance' do
      expect(Rory.application).to eq(Fixture::Application.instance)
    end
  end

  describe '.root' do
    it 'returns root of application' do
      expect(Rory.root).to eq(Rory.application.root)
    end
  end
end