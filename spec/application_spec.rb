require 'spec_helper'

describe Rory::Application do
  describe "#connect_db" do
    it "sets up sequel connection to DB from YAML file" do
      config = { 'development' => :expected }
      YAML.stub!(:load_file).with('config/database.yml').and_return(config)
      Sequel.should_receive(:connect).with(:expected).and_return(stub(:loggers => []))
      Rory::Application.connect_db('development')
    end
  end

  describe "#routes" do
    it "generates a routing table from route configuration" do
      config = {
        'foo/:id/bar' => 'foo#bar',
        'foo' => 'monkeys',
        'this/:path/is/:awesome' => 'awesome#rad'
      }
      YAML.stub!(:load_file).with('config/routes.yml').and_return(config)

      # note: we're comparing the inspected arrays here because the arrays
      # won't be equal, despite appearing the same - this is because the Regexes
      # are different objects.
      Rory::Application.routes.inspect.should == [
        { :presenter => 'foo', :action => 'bar', :regex => /^foo\/(?<id>\w+)\/bar$/},
        { :presenter => 'monkeys', :action => nil, :regex => /^foo$/},
        { :presenter => 'awesome', :action => 'rad', :regex => /^this\/(?<path>\w+)\/is\/(?<awesome>\w+)$/}
      ].inspect
    end
  end
end