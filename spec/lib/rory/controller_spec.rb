describe Rory::Controller do
  before :each do
    @routing = {
      :route => Rory::Route.new('', :to => 'test#letsgo')
    }

    @request = double('Rack::Request', {
      :params => { 'violet' => 'invisibility', :dash => 'superspeed' },
      :script_name => 'script_root'
    })
  end

  it_has_behavior 'path_generation' do
    let(:path_generator) {
      Rory::Controller.new(@request, @routing, Fixture::Application)
    }
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

  describe "#base_path" do
    it "returns script_name from request" do
      controller = Rory::Controller.new(@request, @routing)
      expect(controller.base_path).to eq 'script_root'
    end
  end

  describe "#present" do
    it "calls filters and action from route if exists on controller" do
      controller = FilteredController.new(@request, @routing)
      [:pickle_something, :make_it_tasty, :letsgo, :rub_tummy, :sleep, :render].each do |m|
        expect(controller).to receive(m).ordered
      end
      controller.present
    end

    it "short circuits if a before_action generates a response" do
      controller = FilteredController.new(@request, @routing)
      def controller.pickle_something
        @response = 'stuff'
      end
      [:make_it_tasty, :letsgo, :rub_tummy, :sleep, :render].each do |m|
        expect(controller).to receive(m).never
      end
      controller.present
    end

    it "does not short circuit after_actions if action generates response" do
      controller = FilteredController.new(@request, @routing)
      def controller.letsgo
        @response = 'stuff'
      end
      expect(controller).to receive(:pickle_something).ordered
      expect(controller).to receive(:make_it_tasty).ordered
      expect(controller).to receive(:letsgo).ordered.and_call_original
      expect(controller).to receive(:rub_tummy).ordered
      expect(controller).to receive(:sleep).ordered
      expect(controller).to receive(:render).never
      controller.present
    end

    it "doesn't try to call action from route if nonexistent on controller" do
      controller = FilteredController.new(@request, @routing)
      allow(controller).to receive(:respond_to?).with(:letsgo).and_return(false)
      expect(controller).to receive(:letsgo).never
      [:pickle_something, :make_it_tasty, :rub_tummy, :sleep, :render].each do |m|
        expect(controller).to receive(m).ordered
      end
      controller.present
    end

    it "filters before and after actions on :only and :except" do
      @routing[:route] = Rory::Route.new('', :to => 'test#eat')
      controller = FilteredController.new(@request, @routing)
      expect(controller).to receive(:make_it_tasty).ordered
      expect(controller).to receive(:make_it_nutritious).ordered
      expect(controller).to receive(:eat).ordered
      expect(controller).to receive(:rub_tummy).ordered
      expect(controller).to receive(:smile).ordered
      expect(controller).to receive(:sleep).never
      expect(controller).to receive(:render).ordered
      controller.present
    end

    it "filters before and after actions on :if and :unless" do
      @routing[:route] = Rory::Route.new('', :to => 'test#eat')
      @request = double('Rack::Request', {
        :params => { 'horses' => 'missing' },
        :script_name => 'script_root'
      })
      controller = FilteredController.new(@request, @routing)
      expect(controller).to receive(:make_it_tasty).never
      expect(controller).to receive(:make_it_nutritious).ordered
      expect(controller).to receive(:eat).ordered
      expect(controller).to receive(:rub_tummy).never
      expect(controller).to receive(:smile).ordered
      expect(controller).to receive(:sleep).never
      expect(controller).to receive(:render).ordered
      controller.present
    end

    it "just returns a response if @response exists" do
      controller = Rory::Controller.new(@request, @routing)
      controller.instance_variable_set(:@response, 'Forced response')
      controller.present.should == 'Forced response'
    end

    it "sends a previously set @body to render" do
      controller = Rory::Controller.new(@request, @routing)
      controller.instance_variable_set(:@body, 'Forced body')
      allow(controller).to receive(:render).with(:body => 'Forced body').and_return("Forced response")
      controller.present.should == 'Forced response'
    end

    it "returns the result of render" do
      controller = Rory::Controller.new(@request, @routing)
      allow(controller).to receive(:render).with(:body => nil).and_return("The response")
      controller.present.should == 'The response'
    end
  end

  describe "#render" do
    it "returns the result of #generate_body_for_render as a rack response" do
      controller = Rory::Controller.new(@request, @routing)
      allow(controller).to receive(:default_content_type).and_return("a prison")
      allow(controller).to receive(:generate_for_render).and_return("Valoop!")
      controller.render.should == [
        200,
        {'Content-type' => 'a prison', 'charset' => 'UTF-8'},
        ["Valoop!"]
      ]
    end

    it "returns given body as a rack response" do
      controller = Rory::Controller.new(@request, @routing)
      allow(controller).to receive(:default_content_type).and_return("snooj/woz")
      controller.render(:body => 'Forced body').should == [
        200,
        {'Content-type' => 'snooj/woz', 'charset' => 'UTF-8'},
        ["Forced body"]
      ]
    end
  end

  describe "#json_requested?" do
    it "delegates to dispatcher" do
      controller = Rory::Controller.new(@request, @routing)
      allow(controller).to receive(:dispatcher).and_return(double(:json_requested? => :snakes))
      expect(controller.json_requested?).to eq(:snakes)
    end
  end

  describe "#generate_for_render" do
    it "renders and returns the default template if not json" do
      controller = Rory::Controller.new(@request, @routing)
      allow(controller).to receive(:generate_body_from_template).with("test/letsgo", {}).and_return("Whee")
      controller.generate_for_render.should == "Whee"
    end

    it "renders and returns the given template if not json" do
      controller = Rory::Controller.new(@request, @routing)
      allow(controller).to receive(:generate_body_from_template).with("engines", {}).and_return("Oh dear")
      controller.generate_for_render(:template => 'engines').should == "Oh dear"
    end

    it "returns json version of given json object if json" do
      controller = Rory::Controller.new(@request, @routing)
      allow(controller).to receive(:generate_json_from_object).with(:an_object, {}).and_return("Oh dear")
      controller.generate_for_render(:json => :an_object).should == "Oh dear"
    end
  end

  describe "#generate_json_from_object" do
    it "returns given object as json" do
      controller = Rory::Controller.new(@request, @routing)
      object = double(:to_json => :jsonified)
      controller.generate_json_from_object(object).should == :jsonified
    end
  end

  describe "#generate_body_from_template" do
    it "returns rendered template with given name" do
      controller = Rory::Controller.new(@request, @routing)
      controller.generate_body_from_template('test/letsgo').should == "Let's go content"
    end

    it "returns renderer output" do
      controller = Rory::Controller.new(@request, @routing)
      allow(Rory::Renderer).to receive(:new).
        with('not/real', controller.default_renderer_options).
        and_return(double('Renderer', :render => 'Here ya go'))
      controller.generate_body_from_template('not/real').should == 'Here ya go'
    end

    it "passes layout, exposed locals, and app to renderer" do
      controller = Rory::Controller.new(@request, @routing, :scooby)
      controller.expose(:a => 1)
      allow(controller).to receive(:layout).and_return('pretend')
      renderer_options = {
        :layout => 'pretend',
        :locals => { :a => 1 },
        :app => :scooby,
        :base_path => 'script_root'
      }
      allow(Rory::Renderer).to receive(:new).
        with('also/fake', renderer_options).
        and_return(double('Renderer', :render => 'Scamazing!'))
      controller.generate_body_from_template('also/fake').should == 'Scamazing!'
    end
  end

  describe "#default_content_type" do
    it "returns 'text/html' if not json" do
      controller = Rory::Controller.new(@request, @routing)
      allow(controller).to receive(:json_requested?).and_return(false)
      controller.default_content_type.should == 'text/html'
    end

    it "returns 'application/json' if json requested" do
      controller = Rory::Controller.new(@request, @routing)
      allow(controller).to receive(:json_requested?).and_return(true)
      controller.default_content_type.should == 'application/json'
    end
  end
end
