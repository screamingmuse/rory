describe Rory do
  let!(:new_app) { Class.new(Rory::Application) }

  describe '.application' do
    it 'is by default set to the Rory::Application instance' do
      expect(Rory.application).to eq(new_app.instance)
    end
  end

  describe '.root' do
    it 'returns root of application' do
      expect(Rory.root).to eq(new_app.root)
    end
  end
end