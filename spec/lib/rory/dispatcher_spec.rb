describe Rory::Dispatcher do
  describe "#redirect" do
    it "redirects to given path if path has scheme" do
      dispatcher = Rory::Dispatcher.new({}, Fixture::Application)
      redirection = dispatcher.redirect('http://example.example')
      redirection[0..1].should == [
        302, {'Content-type' => 'text/html', 'Location'=> 'http://example.example' }
      ]
    end

    it "adds request host and scheme and redirects if path has no scheme" do
      request = {}
      request.stub('scheme' => 'happy', 'host_with_port' => 'somewhere.yay')
      dispatcher = Rory::Dispatcher.new(request, Fixture::Application)
      redirection = dispatcher.redirect('/example')
      redirection[0..1].should == [
        302, {'Content-type' => 'text/html', 'Location'=> 'happy://somewhere.yay/example' }
      ]
    end
  end

  describe "#dispatch" do
    let(:dispatcher) { Rory::Dispatcher.new(request, Fixture::Application) }
    let(:request) {
      request = { :whatever => :yay }
      request.stub(:path_info => '/', :request_method => 'GET', :params => {})
      request
    }

    it "renders a 404 if the requested path is invalid" do
      dispatcher.stub(:get_route).and_return(nil)
      dispatcher.dispatch[0..1].should == [404, {"Content-type"=>"text/html"}]
    end

    it "instantiates a controller with the parsed request and calls present" do
      route = Rory::Route.new('', :to => 'stub#index')
      allow(dispatcher).to receive(:get_route).and_return(route)
      dispatcher.dispatch.should == {
        :whatever => :yay,
        :present_called => true # see StubController in /spec/fixture_app
      }
    end

    it "dispatches properly to a scoped controller" do
      route = Rory::Route.new('', :to => 'lumpies#index', :module => 'goose')
      allow(dispatcher).to receive(:get_route).and_return(route)
      dispatcher.dispatch.should == {
        :whatever => :yay,
        :in_scoped_controller => true # see Goose::LumpiesController in /spec/fixture_app
      }
    end

    it "dispatches properly to a nested scoped controller" do
      route = Rory::Route.new('', :to => 'rabbits#index', :module => 'goose/wombat')
      allow(dispatcher).to receive(:get_route).and_return(route)
      dispatcher.dispatch.should == {
        :whatever => :yay,
        :in_scoped_controller => true # see Goose::Wombat::RabbitsController in /spec/fixture_app
      }
    end
  end

  describe "#route" do
    before(:each) do
      @request = {}
      @request.stub(:params => {})
      @dispatcher = Rory::Dispatcher.new(@request, Fixture::Application)
    end

    it "returns route from request if already set" do
      @dispatcher.instance_variable_set(:@routing, { :route => 'snaky pigeons' })
      @dispatcher.route.should == 'snaky pigeons'
    end

    it "matches the path from the request to the routes table" do
      @request.stub(:path_info => '/foo/3/bar', :request_method => 'GET')
      expect(@dispatcher.route).to eq Rory::Route.new('/foo/:id/bar', {
        :to => 'foo#bar',
        :methods => [:get, :post]
      })
    end

    it "uses override method from params if exists" do
      @request.stub(:path_info => '/', :params => { '_method' => 'delete' }, :request_method => 'PUT')
      expect(@dispatcher.route).to eq Rory::Route.new('/', {
        :to => 'root#no_vegetable',
        :methods => [:delete]
      })
    end

    it "deletes override method from params" do
      @request.stub(:path_info => '/', :params => { '_method' => 'delete', 'goats' => 'not_sheep' }, :request_method => 'PUT')
      @dispatcher.route
      expect(@request.params).to eq('goats' => 'not_sheep')
    end

    it "works with empty path" do
      @request.stub(:path_info => '', :request_method => 'GET')
      expect(@dispatcher.route).to eq Rory::Route.new('/', {
        :to => 'root#vegetable',
        :methods => [:get]
      })
    end

    it "works with root url represented by slash" do
      @request.stub(:path_info => '/', :request_method => 'GET')
      expect(@dispatcher.route).to eq Rory::Route.new('/', {
        :to => 'root#vegetable',
        :methods => [:get]
      })
    end

    it "returns nil if no route found" do
      @request.stub(:path_info => '/umbrellas', :request_method => 'GET')
      @dispatcher.route.should be_nil
    end

    it "returns nil if no context" do
      @dispatcher = Rory::Dispatcher.new(@request)
      @dispatcher.route.should be_nil
    end

    it "returns nil if route found but method is not allowed" do
      @request.stub(:path_info => '/foo', :request_method => 'GET')
      @dispatcher.route.should be_nil
    end

    it "assigns named matches to params hash" do
      @request.stub(:path_info => '/this/some-thing_or-other/is/wicked', :request_method => 'GET')
      expect(@dispatcher.route).to eq Rory::Route.new('/this/:path/is/:very_awesome', {
        :to => 'awesome#rad'
      })

      @request.params.should == {:path=>"some-thing_or-other", :very_awesome=>"wicked"}
    end
  end
end
