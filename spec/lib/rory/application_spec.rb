describe Rory::Application do
  describe ".configure" do
    it 'yields the given block to self' do
      Fixture::Application.configure do |c|
        expect(c).to eq(Fixture::Application.instance)
      end
    end
  end

  describe '.config_path' do
    it 'is set to {root}/config by default' do
      expect(Fixture::Application.config_path).to eq(
        Pathname.new(Fixture::Application.root).join('config')
      )
    end

    it 'raises exception if root not set' do
      Rory.application = nil
      class RootlessApp < Rory::Application; end
      expect {
        RootlessApp.config_path
      }.to raise_error(RootlessApp::RootNotConfigured)
      Rory.application = Fixture::Application.instance
    end
  end

  describe ".respond_to?" do
    it 'returns true if the instance said so' do
      expect(Fixture::Application.instance).to receive(:respond_to?).with(:goat).and_return(true)
      expect(Fixture::Application.respond_to?(:goat)).to be_truthy
    end

    it 'does the usual thing if instance says no' do
      expect(Fixture::Application.instance).to receive(:respond_to?).twice.and_return(false)
      expect(Fixture::Application.respond_to?(:to_s)).to be_truthy
      expect(Fixture::Application.respond_to?(:obviously_not_a_real_method)).to be_falsey
    end
  end

  describe ".call" do
    it "forwards arg to new dispatcher, and calls dispatch" do
      dispatcher = double(:dispatch => :expected)
      rack_request = double
      allow(Rack::Request).to receive(:new).with(:env).and_return(rack_request)
      expect(Rory::Dispatcher).to receive(:new).with(rack_request, Fixture::Application.instance).and_return(dispatcher)
      expect(Fixture::Application.call(:env)).to eq(:expected)
    end
  end

  describe ".load_config_data" do
    it "returns parsed yaml file with given name from directory at config_path" do
      allow_any_instance_of(Fixture::Application).to receive(:config_path).and_return('Africa the Great')
      allow(YAML).to receive(:load_file).with(
        File.expand_path(File.join('Africa the Great', 'foo_type.yml'))).
        and_return(:oscar_the_grouch_takes_a_nap)
      expect(Fixture::Application.load_config_data(:foo_type)).to eq(:oscar_the_grouch_takes_a_nap)
    end
  end

  describe ".connect_db" do
    it "sets up sequel connection to DB from YAML file" do
      config = { 'development' => :expected }
      allow_any_instance_of(Fixture::Application).to receive(:load_config_data).with(:database).and_return(config)
      expect(Sequel).to receive(:connect).with(:expected).and_return(double(:loggers => []))
      Fixture::Application.connect_db('development')
    end
  end

  describe ".routes" do
    it "generates a collection of routing objects from route configuration" do
      expect(Fixture::Application.routes).to eq [
        Rory::Route.new('foo/:id/bar', :to => 'foo#bar', :methods => [:get, :post]),
        Rory::Route.new('this/:path/is/:very_awesome', :to => 'awesome#rad'),
        Rory::Route.new('lumpies/:lump', :to => 'lumpies#show', :methods => [:get], :module => 'goose'),
        Rory::Route.new('rabbits/:chew', :to => 'rabbits#chew', :methods => [:get], :module => 'goose/wombat'),
        Rory::Route.new('', :to => 'root#vegetable', :methods => [:get]),
        Rory::Route.new('', :to => 'root#no_vegetable', :methods => [:delete]),
        Rory::Route.new('for_reals/switching', :to => 'for_reals#switching', :methods => [:get]),
        Rory::Route.new('for_reals/:parbles', :to => 'for_reals#srsly', :methods => [:get])
      ]
    end
  end

  describe ".spin_up" do
    it "connects the database" do
      expect_any_instance_of(Rory::Application).to receive(:connect_db)
      Rory::Application.spin_up
    end
  end

  describe '.auto_require_paths' do
    after(:each) do
      Fixture::Application.instance.instance_variable_set(:@auto_require_paths, nil)
    end

    it 'includes models, controllers, and helpers by default' do
      expect(Fixture::Application.auto_require_paths).to eq(['models', 'controllers', 'helpers'])
    end

    it 'accepts new paths' do
      Fixture::Application.auto_require_paths << 'chocolates'
      expect(Fixture::Application.auto_require_paths).to eq(['models', 'controllers', 'helpers', 'chocolates'])
    end
  end

  describe '.require_all_files' do
    it 'requires all files in auto_require_paths' do
      allow_any_instance_of(Fixture::Application).to receive(:auto_require_paths).and_return(['goats', 'rhubarbs'])
      [:goats, :rhubarbs].each do |folder|
        expect(Rory::Support).to receive(:require_all_files_in_directory).
          with(Pathname.new(Fixture::Application.root).join("#{folder}"))
      end
      Fixture::Application.require_all_files
    end
  end

  describe '.use_middleware' do
    it 'adds the given middleware to the stack, retaining args and block' do
      require Fixture::Application.root.join('lib', 'dummy_middleware')
      Fixture::Application.use_middleware DummyMiddleware, :puppy do |dm|
        dm.prefix = 'a salubrious'
      end

      expect(Fixture::Application.instance).to receive(:dispatcher).
        and_return(dispatch_stack_mock = double)
      expect(dispatch_stack_mock).to receive(:call).
        with('a salubrious puppy')
      Fixture::Application.call({})
      Fixture::Application.middleware.clear
    end
  end
end
