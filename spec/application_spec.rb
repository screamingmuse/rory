require 'spec_helper'

describe Rory::Application do
  describe ".configure" do
    it 'yields the given block to self' do
      Fixture::Application.configure do |c|
        c.should == Fixture::Application.instance
      end
    end
  end

  describe '.config_path' do
    it 'is set to {root}/config by default' do
      Fixture::Application.config_path.should ==
        Pathname.new(Fixture::Application.root).join('config')
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
      Fixture::Application.instance.should_receive(:respond_to?).with(:goat).and_return(true)
      Fixture::Application.respond_to?(:goat).should be_true
    end

    it 'does the usual thing if instance says no' do
      Fixture::Application.instance.should_receive(:respond_to?).twice.and_return(false)
      Fixture::Application.respond_to?(:to_s).should be_true
      Fixture::Application.respond_to?(:obviously_not_a_real_method).should be_false
    end
  end

  describe ".call" do
    it "forwards arg to new dispatcher, and calls dispatch" do
      dispatcher = double(:dispatch => :expected)
      rack_request = double
      Rack::Request.stub(:new).with(:env).and_return(rack_request)
      Rory::Dispatcher.should_receive(:new).with(rack_request, Fixture::Application.instance).and_return(dispatcher)
      Fixture::Application.call(:env).should == :expected
    end
  end

  describe ".load_config_data" do
    it "returns parsed yaml file with given name from directory at config_path" do
      Fixture::Application.any_instance.stub(:config_path).and_return('Africa the Great')
      YAML.stub(:load_file).with(
        File.expand_path(File.join('Africa the Great', 'foo_type.yml'))).
        and_return(:oscar_the_grouch_takes_a_nap)
      Fixture::Application.load_config_data(:foo_type).should == :oscar_the_grouch_takes_a_nap
    end
  end

  describe ".connect_db" do
    it "sets up sequel connection to DB from YAML file" do
      config = { 'development' => :expected }
      Fixture::Application.any_instance.stub(:load_config_data).with(:database).and_return(config)
      Sequel.should_receive(:connect).with(:expected).and_return(double(:loggers => []))
      Fixture::Application.connect_db('development')
    end
  end

  describe ".routes" do
    it "generates a routing table from route configuration" do
      # note: we're comparing the inspected arrays here because the arrays
      # won't be equal, despite appearing the same - this is because the Regexes
      # are different objects.
      Fixture::Application.routes.inspect.should == [
        { :controller => 'foo', :action => 'bar', :regex => /^foo\/(?<id>[^\/]+)\/bar$/, :methods => [:get, :post] },
        { :controller => 'monkeys', :action => nil, :regex => /^foo$/, :methods => [:put] },
        { :controller => 'awesome', :action => 'rad', :regex => /^this\/(?<path>[^\/]+)\/is\/(?<very_awesome>[^\/]+)$/},
        { :controller => 'root', :action => 'vegetable', :regex => /^$/, :methods => [:get] }
      ].inspect
    end
  end

  describe ".spin_up" do
    it "connects the database" do
      Rory::Application.any_instance.should_receive(:connect_db)
      Rory::Application.spin_up
    end
  end

  describe '.autoload_paths' do
    after(:each) do
      Fixture::Application.instance.instance_variable_set(:@autoload_paths, nil)
    end

    it 'includes models, controllers, and helpers by default' do
      Fixture::Application.autoload_paths.should == ['models', 'controllers', 'helpers']
    end

    it 'accepts new paths' do
      Fixture::Application.autoload_paths << 'chocolates'
      Fixture::Application.autoload_paths.should == ['models', 'controllers', 'helpers', 'chocolates']
    end
  end

  describe '.autoload_all_files' do
    it 'autoloads all files in autoload_paths' do
      Fixture::Application.any_instance.stub(:autoload_paths).and_return(['goats', 'rhubarbs'])
      [:goats, :rhubarbs].each do |folder|
        Rory::Support.should_receive(:autoload_all_files_in_directory).
          with(Pathname.new(Fixture::Application.root).join("#{folder}"))
      end
      Fixture::Application.autoload_all_files
    end
  end
end
