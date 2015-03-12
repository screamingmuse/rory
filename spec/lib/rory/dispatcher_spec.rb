describe Rory::Dispatcher do
  subject { Rory::Dispatcher.new(request, Fixture::Application) }
  let(:request) { {} }

  describe "#extension" do
    it "returns the extension of the path requested" do
      allow(subject).to receive(:full_path).and_return("whatever/nerds.pickles")
      expect(subject.extension).to eq("pickles")
    end

    it "returns nil if no extension" do
      allow(subject).to receive(:full_path).and_return("whatever/nerds")
      expect(subject.extension).to be_nil
    end
  end

  describe "#path_without_extension" do
    it "returns path with extension removed" do
      allow(subject).to receive(:full_path).and_return("whatever/nerds.pickles")
      expect(subject.path_without_extension).to eq("whatever/nerds")
    end

    it "returns path unchanged if no extension" do
      allow(subject).to receive(:full_path).and_return("whatever/nerds")
      expect(subject.path_without_extension).to eq("whatever/nerds")
    end
  end

  describe "#json_requested?" do
    it "returns true if extension is 'json'" do
      allow(subject).to receive(:extension).and_return("json")
      expect(subject.json_requested?).to be_true
    end

    it "returns false if extension is not 'json'" do
      allow(subject).to receive(:extension).and_return("pachyderms")
      expect(subject.json_requested?).to be_false
    end
  end

  describe "#redirect" do
    it "redirects to given path if path has scheme" do
      redirection = subject.redirect('http://example.example')
      redirection[0..1].should == [
        302, {'Content-type' => 'text/html', 'Location'=> 'http://example.example' }
      ]
    end

    it "adds request host and scheme and redirects if path has no scheme" do
      request.stub('scheme' => 'happy', 'host_with_port' => 'somewhere.yay')
      redirection = subject.redirect('/example')
      redirection[0..1].should == [
        302, {'Content-type' => 'text/html', 'Location'=> 'happy://somewhere.yay/example' }
      ]
    end
  end

  describe "#dispatch" do
    let(:request) { { :whatever => :yay } }
    before(:each) do
      request.stub(:path_info => '/', :request_method => 'GET', :params => {})
    end

    it "renders a 404 if the requested path is invalid" do
      subject.stub(:get_route).and_return(nil)
      subject.dispatch[0..1].should == [404, {"Content-type"=>"text/html"}]
    end

    it "instantiates a controller with the parsed request and calls present" do
      route = Rory::Route.new('', :to => 'stub#index')
      allow(subject).to receive(:get_route).and_return(route)
      subject.dispatch.should == {
        :whatever => :yay,
        :present_called => true # see StubController in /spec/fixture_app
      }
    end

    it "dispatches properly to a scoped controller" do
      route = Rory::Route.new('', :to => 'lumpies#index', :module => 'goose')
      allow(subject).to receive(:get_route).and_return(route)
      subject.dispatch.should == {
        :whatever => :yay,
        :in_scoped_controller => true # see Goose::LumpiesController in /spec/fixture_app
      }
    end

    it "dispatches properly to a nested scoped controller" do
      route = Rory::Route.new('', :to => 'rabbits#index', :module => 'goose/wombat')
      allow(subject).to receive(:get_route).and_return(route)
      subject.dispatch.should == {
        :whatever => :yay,
        :in_scoped_controller => true # see Goose::Wombat::RabbitsController in /spec/fixture_app
      }
    end
  end

  describe "#route" do
    before(:each) do
      request.stub(:params => {})
    end

    it "returns route from request if already set" do
      subject.instance_variable_set(:@routing, { :route => 'snaky pigeons' })
      subject.route.should == 'snaky pigeons'
    end

    it "matches the path from the request to the routes table" do
      request.stub(:path_info => '/foo/3/bar', :request_method => 'GET')
      expect(subject.route).to eq Rory::Route.new('/foo/:id/bar', {
        :to => 'foo#bar',
        :methods => [:get, :post]
      })
    end

    it "ignores extensions when matching path to routes table" do
      request.stub(:path_info => '/foo/3/bar.csv', :request_method => 'GET')
      expect(subject.extension).to eq('csv')
      expect(subject.route).to eq Rory::Route.new('/foo/:id/bar', {
        :to => 'foo#bar',
        :methods => [:get, :post]
      })
    end

    it "uses override method from params if exists" do
      request.stub(:path_info => '/', :params => { '_method' => 'delete' }, :request_method => 'PUT')
      expect(subject.route).to eq Rory::Route.new('/', {
        :to => 'root#no_vegetable',
        :methods => [:delete]
      })
    end

    it "deletes override method from params" do
      request.stub(:path_info => '/', :params => { '_method' => 'delete', 'goats' => 'not_sheep' }, :request_method => 'PUT')
      subject.route
      expect(request.params).to eq('goats' => 'not_sheep')
    end

    it "works with empty path" do
      request.stub(:path_info => '', :request_method => 'GET')
      expect(subject.route).to eq Rory::Route.new('/', {
        :to => 'root#vegetable',
        :methods => [:get]
      })
    end

    it "works with root url represented by slash" do
      request.stub(:path_info => '/', :request_method => 'GET')
      expect(subject.route).to eq Rory::Route.new('/', {
        :to => 'root#vegetable',
        :methods => [:get]
      })
    end

    it "returns nil if no route found" do
      request.stub(:path_info => '/umbrellas', :request_method => 'GET')
      subject.route.should be_nil
    end

    it "returns nil if no context" do
      subject = Rory::Dispatcher.new(request)
      subject.route.should be_nil
    end

    it "returns nil if route found but method is not allowed" do
      request.stub(:path_info => '/foo', :request_method => 'GET')
      subject.route.should be_nil
    end

    it "assigns named matches to params hash" do
      request.stub(:path_info => '/this/some-thing_or-other/is/wicked', :request_method => 'GET')
      expect(subject.route).to eq Rory::Route.new('/this/:path/is/:very_awesome', {
        :to => 'awesome#rad'
      })

      request.params.should == {:path=>"some-thing_or-other", :very_awesome=>"wicked"}
    end
  end
end
