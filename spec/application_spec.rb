require 'spec_helper'

describe Rory::Application do
  describe ".configure" do
    it 'yields the given block to self' do
      Rory::Application.configure do |c|
        c.should == Rory::Application.instance
      end
    end
  end

  describe '.config_path' do
    it 'is set to {Rory.root}/config by default' do
      Rory::Application.config_path.should ==
        File.join(Rory.root, 'config')
    end
  end

  describe ".call" do
    it "forwards arg to new dispatcher, and calls dispatch" do
      dispatcher = stub(:dispatch => :expected)
      rack_request = double
      Rack::Request.stub(:new).with(:env).and_return(rack_request)
      Rory::Dispatcher.should_receive(:new).with(rack_request).and_return(dispatcher)
      Rory::Application.call(:env).should == :expected
    end
  end

  describe ".load_config_data" do
    it "returns parsed yaml file with given name from directory at config_path" do
      Rory::Application.any_instance.stub(:config_path).and_return('Africa the Great')
      YAML.stub!(:load_file).with(
        File.expand_path(File.join('Africa the Great', 'foo_type.yml'))).
        and_return(:oscar_the_grouch_takes_a_nap)
      Rory::Application.load_config_data(:foo_type).should == :oscar_the_grouch_takes_a_nap
    end
  end

  describe ".connect_db" do
    it "sets up sequel connection to DB from YAML file" do
      config = { 'development' => :expected }
      Rory::Application.any_instance.stub(:load_config_data).with(:database).and_return(config)
      Sequel.should_receive(:connect).with(:expected).and_return(stub(:loggers => []))
      Rory::Application.connect_db('development')
    end
  end

  describe ".connection" do
    it "returns established Sequel connection" do
      config = { 'development' => :expected }
      Rory::Application.any_instance.stub(:load_config_data).with(:database).and_return(config)
      db_connection = double(:loggers => [])
      Sequel.stub(:connect).with(:expected).and_return(db_connection)
      Rory::Application.connect_db('development')
      Rory::Application.connection.should == db_connection
    end
  end

  describe ".routes" do
    it "generates a routing table from route configuration" do
      config = {
        'foo/:id/bar' => 'foo#bar',
        'foo' => 'monkeys',
        'this/:path/is/:very_awesome' => 'awesome#rad'
      }
      Rory::Application.any_instance.stub(:load_config_data).with(:routes).and_return(config)

      # note: we're comparing the inspected arrays here because the arrays
      # won't be equal, despite appearing the same - this is because the Regexes
      # are different objects.
      Rory::Application.routes.inspect.should == [
        { :presenter => 'foo', :action => 'bar', :regex => /^foo\/(?<id>[^\/]+)\/bar$/},
        { :presenter => 'monkeys', :action => nil, :regex => /^foo$/},
        { :presenter => 'awesome', :action => 'rad', :regex => /^this\/(?<path>[^\/]+)\/is\/(?<very_awesome>[^\/]+)$/}
      ].inspect
    end
  end

  describe ".spin_up" do
    it "connects the database" do
      Rory::Application.any_instance.should_receive(:connect_db)
      Rory::Application.spin_up
    end
  end
end
