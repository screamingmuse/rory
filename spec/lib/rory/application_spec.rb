describe Rory::Application do
  let(:subject) {
    Class.new(Rory::Application).tap { |app|
      app.root = "whatever"
      app.turn_off_request_logging!
    }
  }

  describe ".configure" do
    it 'yields the given block to self' do
      subject.configure do |c|
        expect(c).to eq(subject.instance)
      end
    end
  end

  describe '.config_path' do
    it 'is set to {root}/config by default' do
      expect(subject.config_path).to eq(
        Pathname.new(subject.root).join('config')
      )
    end

    it 'raises exception if root not set' do
      Rory.application = nil
      class RootlessApp < Rory::Application; end
      expect {
        RootlessApp.config_path
      }.to raise_error(RootlessApp::RootNotConfigured)
      Rory.application = subject.instance
    end
  end

  describe '.log_path' do
    it 'is set to {root}/config by default' do
      expect(subject.log_path).to eq(
        Pathname.new(subject.root).join('log')
      )
    end

    it 'raises exception if root not set' do
      Rory.application = nil
      class RootlessApp < Rory::Application; end
      expect {
        RootlessApp.config_path
      }.to raise_error(RootlessApp::RootNotConfigured)
      Rory.application = subject.instance
    end
  end

  describe ".respond_to?" do
    it 'returns true if the instance said so' do
      expect(subject.instance).to receive(:respond_to?).with(:goat).and_return(true)
      expect(subject.respond_to?(:goat)).to be_truthy
    end

    it 'does the usual thing if instance says no' do
      expect(subject.instance).to receive(:respond_to?).twice.and_return(false)
      expect(subject.respond_to?(:to_s)).to be_truthy
      expect(subject.respond_to?(:obviously_not_a_real_method)).to be_falsey
    end
  end

  describe ".call" do
    it "forwards arg to new dispatcher, and calls dispatch" do
      dispatcher = double(:dispatch => :expected)
      rack_request = double(:media_type => 'application/json')
      env = { "rack.input" => double(:read => {}) }
      allow(Rack::Request).to receive(:new).with(env).and_return(rack_request)
      expect(Rory::Dispatcher).to receive(:new).with(rack_request, subject.instance).and_return(dispatcher)
      expect(subject.call(env)).to eq(:expected)
    end
  end

  describe ".log_file" do
    it "creates the log file directory if it does not exist" do
      file = double(:sync= => true)
      allow(File).to receive(:exists?).and_return(false)
      allow(Dir).to receive(:mkdir).and_return(true)
      allow(File).to receive(:open).and_return(file)
      expect(subject.log_file).to eq(file)
    end

    it "returns the file and does not create the log file directory if it does not exist" do
      file = double(:sync= => true)
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:open).and_return(file)
      expect(subject.log_file).to eq(file)
    end
  end

  describe ".logger" do
    it "reutrns a logger" do
      logger = double
      allow_any_instance_of(subject).to receive(:log_file)
      allow(Logger).to receive(:new).and_return(logger)
      expect(subject.logger).to eq(logger)
    end
  end

  describe ".use_default_middleware" do
    it "adds middleware when request logging is on" do
      allow(subject.instance).to receive(:request_logging_on?).and_return(true)
      allow(subject.instance).to receive(:logger).and_return(:the_logger)
      subject.use_default_middleware
      expect(subject.middleware.count).to_not eq(0)
    end

    it "does not add middleware when request logging is off" do
      allow(subject.instance).to receive(:request_logging_on?).and_return(false)
      allow(subject.instance).to receive(:logger).and_return(:the_logger)
      subject.use_default_middleware
      expect(subject.middleware.count).to eq(0)
    end
  end

  describe ".load_config_data" do
    it "returns parsed yaml file with given name from directory at config_path" do
      allow_any_instance_of(subject).to receive(:config_path).and_return('Africa the Great')
      allow(YAML).to receive(:load_file).with(
        File.expand_path(File.join('Africa the Great', 'foo_type.yml'))).
        and_return(:oscar_the_grouch_takes_a_nap)
      expect(subject.load_config_data(:foo_type)).to eq(:oscar_the_grouch_takes_a_nap)
    end
  end

  describe ".connect_db" do
    it "sets up sequel connection to DB from YAML file" do
      config = { 'development' => :expected }
      logger_array = []
      allow(subject.instance).to receive(:logger).and_return(:the_logger)
      allow(subject.instance).to receive(:load_config_data).with(:database).and_return(config)
      expect(Sequel).to receive(:connect).with(:expected).and_return(double(:loggers => logger_array))
      subject.connect_db('development')
      expect(logger_array).to match_array([:the_logger])
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
      subject.instance.instance_variable_set(:@auto_require_paths, nil)
    end

    it 'includes models, controllers, and helpers by default' do
      expect(subject.auto_require_paths).to eq(['models', 'controllers', 'helpers'])
    end

    it 'accepts new paths' do
      subject.auto_require_paths << 'chocolates'
      expect(subject.auto_require_paths).to eq(['models', 'controllers', 'helpers', 'chocolates'])
    end
  end

  describe '.require_all_files' do
    it 'requires all files in auto_require_paths' do
      allow_any_instance_of(subject).to receive(:auto_require_paths).and_return(['goats', 'rhubarbs'])
      [:goats, :rhubarbs].each do |folder|
        expect(Rory::Support).to receive(:require_all_files_in_directory).
          with(Pathname.new(subject.root).join("#{folder}"))
      end
      subject.require_all_files
    end
  end

  describe '.use_middleware' do
    it 'adds the given middleware to the stack, retaining args and block' do
      require_relative '../../fixture_app/lib/dummy_middleware'
      subject.use_middleware DummyMiddleware, :puppy do |dm|
        dm.prefix = 'a salubrious'
      end

      expect(subject.instance).to receive(:dispatcher).
        and_return(dispatch_stack_mock = double)
      expect(dispatch_stack_mock).to receive(:call).
        with('a salubrious puppy')
      subject.call({})
      subject.middleware.clear
    end
  end

  context "with fixture application" do
    subject { Fixture::Application }
    describe ".routes" do
      it "generates a collection of routing objects from route configuration" do
        expect(subject.routes).to eq [
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
  end
end