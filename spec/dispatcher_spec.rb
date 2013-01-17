require 'spec_helper'

class DummyPresenter
  def initialize(args)
    @args = args
  end

  def present
    @args[:present_called] = true
    @args
  end
end

describe Rory::Dispatcher do
  describe "#dispatch" do
    it "renders a 404 if the requested path is invalid" do
      @dispatcher = Rory::Dispatcher.new({})
      @dispatcher.stub(:get_route).and_return(nil)
      @dispatcher.dispatch[0..1].should == [404, {"Content-type"=>"text/html"}]
    end

    it "instantiates a presenter with the parsed request and calls present" do
      @dispatcher = Rory::Dispatcher.new({ :whatever => :yay })
      route = {
        :presenter => 'dummy'
      }
      @dispatcher.stub(:get_route).and_return(route)
      @dispatcher.dispatch.should == {
        :whatever => :yay,
        :route => route,
        :dispatcher => @dispatcher,
        :present_called => true
      }
    end
  end

  describe "#get_route" do
    before(:each) do
      @dispatcher = Rory::Dispatcher.new({})
      Rory::Application.stub(:routes).and_return([
        {
          :presenter => 'monkeys',
          :action => nil,
          :regex => /^foo$/
        },
        {
          :presenter => 'awesome',
          :action => 'rad',
          :regex => /^this\/(?<path>\w+)\/is\/(?<awesome>\w+)$/
        }
      ])
    end

    it "matches the given path to the routes table" do
      @dispatcher.get_route('foo').should == {
        :presenter => 'monkeys',
        :action => nil,
        :regex => /^foo$/,
        :params => {}
      }
    end

    it "assigns named matches to params hash" do
      @dispatcher.get_route('this/thing/is/wicked').should == {
        :presenter => 'awesome',
        :action => 'rad',
        :regex => /^this\/(?<path>\w+)\/is\/(?<awesome>\w+)$/,
        :params => {
          :path => 'thing',
          :awesome => 'wicked'
        }
      }
    end
  end
end