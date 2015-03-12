describe Rory::Route do
  describe '#name' do
    it 'returns concatenated controller and action' do
      route = described_class.new('/whatever', :to => 'pigeons#index')
      expect(route.name).to eq 'pigeons_index'
    end
  end

  describe "#path_params" do
    it "extracts params from path into hash" do
      route = described_class.new('/spoons/:spoon_id/forks/:fork_id', :to => 'cutlery#index')
      expect(route.path_params('spoons/4/forks/yay')).to eq({ :spoon_id => "4", :fork_id => "yay" })
    end
  end
end