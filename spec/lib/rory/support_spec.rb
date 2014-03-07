describe Rory::Support do
  describe ".camelize" do
    it "camelizes given snake-case string" do
      Rory::Support.camelize('water_under_bridge').should == 'WaterUnderBridge'
    end

    it "leaves already camel-cased string alone" do
      Rory::Support.camelize('OliverDrankGasoline').should == 'OliverDrankGasoline'
    end
  end

  describe '.require_all_files_in_directory' do
    it 'requires all files from given path' do
      Dir.stub(:[]).with(Pathname.new('spinach').join('**', '*.rb')).
        and_return(["pumpkins", "some_guy_dressed_as_liberace"])
      Rory::Support.should_receive(:require).with("pumpkins")
      Rory::Support.should_receive(:require).with("some_guy_dressed_as_liberace")
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
      Rory::Support.constantize('OrigamiDeliveryMan').
        should == OrigamiDeliveryMan
    end

    it 'returns constant from snake-case string' do
      Rory::Support.constantize('origami_delivery_man').
        should == OrigamiDeliveryMan
    end

    it 'returns namespaced constant' do
      Rory::Support.constantize(
        'origami_delivery_man/under_where/skippy'
      ).should == OrigamiDeliveryMan::UnderWhere::Skippy
    end
  end

  describe '.tokenize' do
    it 'creates snake_case version of string' do
      described_class.tokenize('Albus Dumbledore & his_friend').should == 'albus_dumbledore_and_his_friend'
    end

    it 'uncamelizes' do
      described_class.tokenize('thisStrangeJavalikeWord').should == 'this_strange_javalike_word'
    end

    it 'returns nil if given nil' do
      described_class.tokenize(nil).should be_nil
    end

    it 'also handles symbols' do
      described_class.tokenize(:yourFaceIsNice).should == 'your_face_is_nice'
    end
  end
end