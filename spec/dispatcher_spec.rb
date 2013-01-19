require 'spec_helper'

describe Rory::Dispatcher do
  describe "#redirect" do
    it "redirects to given path if path has scheme" do
      dispatcher = Rory::Dispatcher.new({})
      redirection = dispatcher.redirect('http://example.example')
      redirection[0..1].should == [
        302, {'Content-type' => 'text/html', 'Location'=> 'http://example.example' }
      ]
    end

    it "adds request host and scheme and redirects if path has no scheme" do
      dispatcher = Rory::Dispatcher.new({
        'rack.url_scheme' => 'happy',
        'HTTP_HOST' => 'somewhere.yay'
      })
      redirection = dispatcher.redirect('/example')
      redirection[0..1].should == [
        302, {'Content-type' => 'text/html', 'Location'=> 'happy://somewhere.yay/example' }
      ]
    end
  end

  describe "#dispatch" do
    it "renders a 404 if the requested path is invalid" do
      @dispatcher = Rory::Dispatcher.new({})
      @dispatcher.stub(:get_route).and_return(nil)
      @dispatcher.dispatch[0..1].should == [404, {"Content-type"=>"text/html"}]
    end

    it "instantiates a presenter with the parsed request and calls present" do
      @dispatcher = Rory::Dispatcher.new({ :whatever => :yay })
      route = {
        :presenter => 'stub'
      }
      @dispatcher.stub(:get_route).and_return(route)
      @dispatcher.dispatch.should == {
        :whatever => :yay,
        :route => route,
        :dispatcher => @dispatcher,
        :present_called => true # see StubPresenter in /spec/fixture_app
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