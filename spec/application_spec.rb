require 'spec_helper'

describe Rory::Application do
  describe ".call" do
    it "forwards arg to new dispatcher, and calls dispatch" do
      dispatcher = stub(:dispatch => :expected)
      Rory::Dispatcher.should_receive(:new).with(:env).and_return(dispatcher)
      Rory::Application.call(:env).should == :expected
    end
  end

  describe ".connect_db" do
    it "sets up sequel connection to DB from YAML file" do
      config = { 'development' => :expected }
      YAML.stub!(:load_file).with('config/database.yml').and_return(config)
      Sequel.should_receive(:connect).with(:expected).and_return(stub(:loggers => []))
      Rory::Application.connect_db('development')
    end
  end

  describe ".routes" do
    it "generates a routing table from route configuration" do
      config = {
        'foo/:id/bar' => 'foo#bar',
        'foo' => 'monkeys',
        'this/:path/is/:very_awesome' => 'awesome#rad'
      }
      YAML.stub!(:load_file).with('config/routes.yml').and_return(config)

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