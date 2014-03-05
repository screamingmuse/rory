describe Rory::Route do
  describe '#name' do
    it 'returns concatenated controller and action' do
      route = described_class.new('/whatever', :to => 'pigeons#index')
      expect(route.name).to eq 'pigeons_index'
    end
  end
end