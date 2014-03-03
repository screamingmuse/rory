describe Rory::Controller do
  before :each do
    @routing = {
      :route => {
        :controller => 'test',
        :action => 'letsgo'
      }
    }

    @request = double('Rack::Request', {
      :params => { 'violet' => 'invisibility', :dash => 'superspeed' },
      :script_name => 'script_root'
    })
  end

  describe '#layout' do
    it 'defaults to nil' do
      controller = Rory::Controller.new(@request, @routing)
      controller.layout.should be_nil
    end
  end

  describe '#params' do
    it 'returns params from request, converted for indifferent key access' do
      controller = Rory::Controller.new(@request, @routing)
      expect(controller.params).to eq({
        'violet' => 'invisibility',
        'dash' => 'superspeed',
        :violet => 'invisibility',
        :dash => 'superspeed'
      })
    end
  end

  describe "#render" do
    it "returns renderer output" do
      controller = Rory::Controller.new(@request, @routing)
      allow(Rory::Renderer).to receive(:new).
        with('not/real', controller.default_renderer_options).
        and_return(double('Renderer', :render => 'Here ya go'))
      controller.render('not/real').should == 'Here ya go'
    end

    it "passes layout, exposed locals, and app to renderer" do
      controller = Rory::Controller.new(@request, @routing, :scooby)
      controller.expose(:a => 1)
      allow(controller).to receive(:layout).and_return('pretend')
      renderer_options = {
        :layout => 'pretend',
        :locals => { :a => 1 },
        :app => :scooby,
        :base_url => 'script_root'
      }
      allow(Rory::Renderer).to receive(:new).
        with('also/fake', renderer_options).
        and_return(double('Renderer', :render => 'Scamazing!'))
      controller.render('also/fake').should == 'Scamazing!'
    end
  end

  describe "#redirect" do
    it "delegates to dispatcher from request" do
      @routing[:dispatcher] = dispatcher = double
      dispatcher.should_receive(:redirect).with(:whatever)
      controller = Rory::Controller.new(@request, @routing)
      controller.redirect(:whatever)
    end
  end

  describe "#render_not_found" do
    it "delegates to dispatcher from request" do
      @routing[:dispatcher] = dispatcher = double
      dispatcher.should_receive(:render_not_found)
      controller = Rory::Controller.new(@request, @routing)
      controller.render_not_found
    end
  end

  describe "#present" do
    it "calls action from route if exists on controller" do
      controller = Rory::Controller.new(@request, @routing)
      controller.stub(:render)
      controller.should_receive('letsgo')
      controller.present
    end

    it "doesn't try to call action from route if nonexistent on controller" do
      controller = Rory::Controller.new(@request, @routing)
      controller.stub(:render)
      controller.stub(:respond_to?).with('letsgo').and_return(false)
      controller.should_receive('letsgo').never
      controller.present
    end

    it "just returns a response if @response exists" do
      controller = Rory::Controller.new(@request, @routing)
      controller.instance_variable_set(:@response, 'Forced response')
      controller.present.should == 'Forced response'
    end

    it "renders and returns the default template as a rack response" do
      controller = Rory::Controller.new(@request, @routing)
      controller.present.should == [
        200,
        {'Content-type' => 'text/html', 'charset' => 'UTF-8'},
        ["Let's go content"]
      ]
    end

    it "returns previously set @body as a rack response" do
      controller = Rory::Controller.new(@request, @routing)
      controller.instance_variable_set(:@body, 'Forced body')
      controller.should_receive(:render).never
      controller.present.should == [
        200,
        {'Content-type' => 'text/html', 'charset' => 'UTF-8'},
        ["Forced body"]
      ]
    end
  end
end
