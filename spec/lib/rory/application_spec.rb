require_relative '../../fixture_app/lib/dummy_middleware'

RSpec.describe Rory::Application do
  let(:subject) {
    Object.const_set(test_rory_app_name, Class.new(Rory::Application).tap { |app|
      app.root = root
      app.turn_off_request_logging!
    })
    Object.const_get(test_rory_app_name)
  }

  let(:test_rory_app_name){
    "TestRory#{('a'..'z').to_a.sample(5).join}"
  }
  let(:root){"spec/fixture_app"}

  before do
    Rory::Application.initializers.clear
    Rory::Application.initializer_default_middleware
  end

  describe ".root=" do
    let(:root) { "current_app" }
    before { `ln -s spec/fixture_app current_app` }
    after { `rm current_app` }

    it 'appends to the load path' do
      expect($:).to receive(:unshift).with(Pathname("current_app").realpath)
      subject
    end
  end

  describe ".root" do
    let(:root) { "current_app" }
    before { `ln -s spec/fixture_app current_app` }
    after { `rm current_app` }

    it "returns the realpath" do
      expect(subject.root.to_s).to match(/spec\/fixture_app/)
    end
  end

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

  describe ".dispatcher" do
    it "returns new dispatcher rack app" do
      allow(Rory::Dispatcher).to receive(:rack_app).
        with(subject).and_return(:dispatcher_app)
      expect(subject.dispatcher).to eq(:dispatcher_app)
    end
  end

  describe ".call" do
    it "calls the stack with the given environment" do
      stack = double
      allow(stack).to receive(:call).with(:the_env).and_return(:expected)
      expect(subject.instance).to receive(:stack).and_return(stack)
      expect(subject.call(:the_env)).to eq(:expected)
    end
  end

  describe ".log_file" do
    it "creates the log file directory if it does not exist" do
      file = double(:sync= => true)
      allow(File).to receive(:exist?).and_return(false)
      allow(Dir).to receive(:mkdir).and_return(true)
      allow(File).to receive(:open).and_return(file)
      expect(subject.log_file).to eq(file)
    end

    it "returns the file and does not create the log file directory if it does not exist" do
      file = double(:sync= => true)
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:open).and_return(file)
      expect(subject.log_file).to eq(file)
    end
  end

  describe ".logger" do
    it "returns a logger" do
      logger = double
      allow_any_instance_of(subject).to receive(:log_file)
      allow(Logger).to receive(:new).and_return(logger)
      expect(subject.logger).to eq(logger)
    end
  end

  describe ".turn_off_request_logging!" do
    it "resets stack and turns off request logging" do
      subject.instance.instance_variable_set(:@request_logging, :true)
      expect(subject.request_logging_on?).to eq(true)
      expect(subject.instance).to receive(:reset_stack)
      subject.turn_off_request_logging!
      expect(subject.request_logging_on?).to eq(false)
    end
  end

  describe ".filter_parameters" do
    it "resets stack and sets parameters to filter" do
      expect(subject.instance).to receive(:reset_stack)
      subject.filter_parameters :dog, :kitty
      expect(subject.parameters_to_filter).to eq([:dog, :kitty])
    end
  end

  describe ".reset_stack" do
    it "clears memoization of stack" do
      stack = subject.stack
      expect(subject.stack).to eq(stack)
      subject.reset_stack
      expect(subject.stack).not_to eq(stack)
    end
  end

  describe ".stack" do
    it "returns a rack builder instance with configured middleware" do
      builder = double
      allow(subject.instance).to receive(:dispatcher).
        and_return(:the_dispatcher)
      allow(Rack::Builder).to receive(:new).and_return(builder)
      subject.use_middleware :horse
      expect(subject.instance).to receive(:request_middleware).with(no_args)
      expect(builder).to receive(:use).with(:horse)
      expect(builder).to receive(:run).with(:the_dispatcher)
      expect(subject.stack).to eq(builder)
    end
  end

  describe ".parameters_to_filter" do
    it "returns [:password] by default" do
      expect(subject.parameters_to_filter).to eq([:password])
    end
  end

  describe ".use_default_middleware" do
    it "adds middleware when request logging is on" do
      allow(subject.instance).to receive(:request_logging_on?).and_return(true)
      allow(subject.instance).to receive(:parameters_to_filter).and_return([:horses])
      allow(subject.instance).to receive(:logger).and_return(:the_logger)
      expect(subject.instance).to receive(:use_middleware).with(Rory::RequestId, :uuid_prefix => Rory::Support.tokenize(test_rory_app_name))
      expect(subject.instance).to receive(:use_middleware).with(Rack::JSONBodyParser)
      expect(subject.instance).to receive(:use_middleware).with(Rack::CommonLogger, :the_logger)
      expect(subject.instance).to receive(:use_middleware).with(Rory::RequestParameterLogger, :the_logger, :filters => [:horses])
      subject.request_middleware
    end

    it "does not add middleware when request logging is off" do
      allow(subject.instance).to receive(:request_logging_on?).and_return(false)
      expect(subject.instance).to receive(:use_middleware).never
      subject.request_middleware
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

    it 'includes initializers, models, controllers, and helpers by default' do
      expect(subject.auto_require_paths).to eq(['config/initializers', 'models', 'controllers', 'helpers'])
    end

    it 'accepts new paths' do
      subject.auto_require_paths << 'chocolates'
      expect(subject.auto_require_paths).to eq(['config/initializers', 'models', 'controllers', 'helpers', 'chocolates'])
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

    describe ".parameters_to_filter" do
      it "returns overridden parameters" do
        expect(subject.parameters_to_filter).to eq([:orcas, :noodles])
      end
    end
  end

  describe ".initializers" do
    describe ".insert_after" do
      it "inserts initializer before another" do
        probe = []
        Rory::Application.initializers.add("insert_after.A") { probe << "insert_after.A" }
        Rory::Application.initializers.add("insert_after.B") { probe << "insert_after.B" }
        Rory::Application.initializers.insert_after("insert_after.A", "insert_after.C") { probe << "insert_after.C" }

        expect { subject.run_initializers }.to change { probe }.from([]).
          to(%w(insert_after.A insert_after.C insert_after.B))
      end
    end

    describe ".add" do
      it "runs the code inside any initializer block" do
        probe = :initializers_not_run
        Rory::Application.initializers.add "add.test" do
          probe = :was_run
        end
        expect { subject.run_initializers }.to change { probe }.from(:initializers_not_run).to(:was_run)
      end

      it "passes the app instance to the block" do
        probe = :block_not_called
        Rory::Application.initializers.add "add.test_passes_app" do |app|
          probe = :block_called
          expect(app.class.superclass).to eq Rory::Application
        end
        expect { subject.run_initializers }.to change { probe }.from(:block_not_called).to(:block_called)
      end
    end
  end

  describe "#middleware" do
    before { subject.middleware.clear }

    describe "#insert_before" do
      it "places the middleware order right after the given class" do
        subject.instance.instance_variable_set(:@request_logging, :true)
        Rory::Application.initializers.add "insert_before.dummy_middleware" do |app|
          app.middleware.insert_before Rory::RequestId, DummyMiddleware, :puppy
        end
        subject.run_initializers
        expect(subject.middleware.map(&:klass)).to eq [DummyMiddleware,
                                                       Rory::RequestId,
                                                       Rack::JSONBodyParser,
                                                       Rack::CommonLogger,
                                                       Rory::RequestParameterLogger]
      end
    end
  end
end
