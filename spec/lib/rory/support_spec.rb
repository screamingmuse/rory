describe Rory::Support do
  describe ".camelize" do
    it "camelizes given snake-case string" do
      expect(Rory::Support.camelize('water_under_bridge')).to eq('WaterUnderBridge')
    end

    it "leaves already camel-cased string alone" do
      expect(Rory::Support.camelize('OliverDrankGasoline')).to eq('OliverDrankGasoline')
    end
  end

  describe '.require_all_files_in_directory' do
    it 'requires all files from given path' do
      allow(Dir).to receive(:[]).with(Pathname.new('spinach').join('**', '*.rb')).
        and_return(["pumpkins", "some_guy_dressed_as_liberace"])
      expect(Rory::Support).to receive(:require).with("pumpkins")
      expect(Rory::Support).to receive(:require).with("some_guy_dressed_as_liberace")
      Rory::Support.require_all_files_in_directory('spinach')
    end
  end

  describe '.constantize' do
    before(:all) do
      Object.const_set('OrigamiDeliveryMan', Module.new)
      OrigamiDeliveryMan.const_set('UnderWhere', Module.new)
      OrigamiDeliveryMan::UnderWhere.const_set('Skippy', Module.new)
    end

    after(:all) do
      Object.send(:remove_const, :OrigamiDeliveryMan)
    end

    it 'returns constant from camelized name' do
      expect(Rory::Support.constantize('OrigamiDeliveryMan')).
        to eq(OrigamiDeliveryMan)
    end

    it 'returns constant from snake-case string' do
      expect(Rory::Support.constantize('origami_delivery_man')).
        to eq(OrigamiDeliveryMan)
    end

    it 'returns namespaced constant' do
      expect(Rory::Support.constantize(
        'origami_delivery_man/under_where/skippy'
      )).to eq(OrigamiDeliveryMan::UnderWhere::Skippy)
    end
  end

  describe '.tokenize' do
    it 'creates snake_case version of string' do
      expect(described_class.tokenize('Albus Dumbledore & his_friend')).to eq('albus_dumbledore_and_his_friend')
    end

    it 'uncamelizes' do
      expect(described_class.tokenize('thisStrangeJavalikeWord')).to eq('this_strange_javalike_word')
    end

    it 'returns nil if given nil' do
      expect(described_class.tokenize(nil)).to be_nil
    end

    it 'also handles symbols' do
      expect(described_class.tokenize(:yourFaceIsNice)).to eq('your_face_is_nice')
    end
  end

  describe ".encode_as_json" do
    it "returns given object as json" do
      object = double(:to_json => :jsonified)
      expect(described_class.encode_as_json(object)).to eq(:jsonified)
    end

    it "calls to_hash first if object responds to it" do
      object = double(:to_hash => { 'april' => 'friday' })
      expect(described_class.encode_as_json(object)).to eq({ 'april' => 'friday' }.to_json)
    end

    it "converts each member of an array" do
      object = [
        double(:to_hash => :smurf),
        double(:to_hash => :nerf)
      ]
      expect(described_class.encode_as_json(object)).to eq([:smurf, :nerf].to_json)
    end
  end
end