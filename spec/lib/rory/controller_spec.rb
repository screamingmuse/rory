describe Rory::Controller do
  subject { Rory::Controller.new(@request, @routing) }

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
      expect(subject.layout).to be_nil
    end
  end

  describe '#params' do
    it 'returns params from request, converted for indifferent key access' do
      expect(subject.params).to eq({
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
      expect(dispatcher).to receive(:redirect).with(:whatever)
      subject.redirect(:whatever)
    end
  end

  describe "#render_not_found" do
    it "delegates to dispatcher from request" do
      @routing[:dispatcher] = dispatcher = double
      expect(dispatcher).to receive(:render_not_found)
      subject.render_not_found
    end
  end

  describe "#base_path" do
    it "returns script_name from request" do
      expect(subject.base_path).to eq 'script_root'
    end
  end

  describe "#present" do
    context "with filters" do
      subject { FilteredController.new(@request, @routing) }

      it "calls filters and action from route if exists on controller" do
        [:pickle_something, :make_it_tasty, :letsgo, :rub_tummy, :sleep, :render].each do |m|
          expect(subject).to receive(m).ordered
        end
        subject.present
      end

      it "short circuits if a before_action generates a response" do
        def subject.pickle_something
          @response = 'stuff'
        end
        [:make_it_tasty, :letsgo, :rub_tummy, :sleep, :render].each do |m|
          expect(subject).to receive(m).never
        end
        subject.present
      end

      it "does not short circuit after_actions if action generates response" do
        def subject.letsgo
          @response = 'stuff'
        end
        expect(subject).to receive(:pickle_something).ordered
        expect(subject).to receive(:make_it_tasty).ordered
        expect(subject).to receive(:letsgo).ordered.and_call_original
        expect(subject).to receive(:rub_tummy).ordered
        expect(subject).to receive(:sleep).ordered
        expect(subject).to receive(:render).never
        subject.present
      end

      it "doesn't try to call action from route if nonexistent on controller" do
        allow(@routing[:route]).to receive(:action).and_return('no worries')
        [:pickle_something, :make_it_tasty, :rub_tummy, :sleep, :render].each do |m|
          expect(subject).to receive(m).ordered
        end
        expect { subject.present }.not_to raise_error
      end

      it "filters before and after actions on :only and :except" do
        @routing[:route] = Rory::Route.new('', :to => 'test#eat')
        expect(subject).to receive(:make_it_tasty).ordered
        expect(subject).to receive(:make_it_nutritious).ordered
        expect(subject).to receive(:eat).ordered
        expect(subject).to receive(:rub_tummy).ordered
        expect(subject).to receive(:smile).ordered
        expect(subject).to receive(:sleep).never
        expect(subject).to receive(:render).ordered
        subject.present
      end

      it "filters before and after actions on :if and :unless" do
        @routing[:route] = Rory::Route.new('', :to => 'test#eat')
        @request = double('Rack::Request', {
          :params => { 'horses' => 'missing' },
          :script_name => 'script_root'
        })
        expect(subject).to receive(:make_it_tasty).never
        expect(subject).to receive(:make_it_nutritious).ordered
        expect(subject).to receive(:eat).ordered
        expect(subject).to receive(:rub_tummy).never
        expect(subject).to receive(:smile).ordered
        expect(subject).to receive(:sleep).never
        expect(subject).to receive(:render).ordered
        subject.present
      end
    end

    it "just returns a response if @response exists" do
      subject.instance_variable_set(:@response, 'Forced response')
      expect(subject.present).to eq('Forced response')
    end

    it "sends a previously set @body to render" do
      subject.instance_variable_set(:@body, 'Forced body')
      allow(subject).to receive(:render).with(:body => 'Forced body').and_return("Forced response")
      expect(subject.present).to eq('Forced response')
    end

    it "returns the result of render" do
      allow(subject).to receive(:render).with(:body => nil).and_return("The response")
      expect(subject.present).to eq('The response')
    end
  end

  describe "#render" do
    it "returns the result of #generate_body_for_render as a rack response" do
      allow(subject).to receive(:default_content_type).and_return("a prison")
      allow(subject).to receive(:generate_for_render).and_return("Valoop!")
      expect(subject.render).to eq([
        200,
        {'Content-type' => 'a prison', 'charset' => 'UTF-8'},
        ["Valoop!"]
      ])
    end

    it "returns given body as a rack response" do
      allow(subject).to receive(:default_content_type).and_return("snooj/woz")
      expect(subject.render(:body => 'Forced body')).to eq([
        200,
        {'Content-type' => 'snooj/woz', 'charset' => 'UTF-8'},
        ["Forced body"]
      ])
    end
  end

  describe "#json_requested?" do
    it "delegates to dispatcher" do
      allow(subject).to receive(:dispatcher).and_return(double(:json_requested? => :snakes))
      expect(subject.json_requested?).to eq(:snakes)
    end
  end

  describe "#generate_for_render" do
    it "renders and returns the default template if not json" do
      allow(subject).to receive(:generate_body_from_template).with("test/letsgo", {}).and_return("Whee")
      expect(subject.generate_for_render).to eq("Whee")
    end

    it "renders and returns the given template if not json" do
      allow(subject).to receive(:generate_body_from_template).with("engines", {}).and_return("Oh dear")
      expect(subject.generate_for_render(:template => 'engines')).to eq("Oh dear")
    end

    it "returns json version of given json object if json" do
      allow(subject).to receive(:generate_json_from_object).with(:an_object, {}).and_return("Oh dear")
      expect(subject.generate_for_render(:json => :an_object)).to eq("Oh dear")
    end
  end

  describe "#generate_json_from_object" do
    it "returns given object as json" do
      object = double(:to_json => :jsonified)
      expect(subject.generate_json_from_object(object)).to eq(:jsonified)
    end
  end

  describe "#generate_body_from_template" do
    it "returns rendered template with given name" do
      expect(subject.generate_body_from_template('test/letsgo')).to eq("Let's go content")
    end

    it "returns renderer output" do
      allow(Rory::Renderer).to receive(:new).
        with('not/real', subject.default_renderer_options).
        and_return(double('Renderer', :render => 'Here ya go'))
      expect(subject.generate_body_from_template('not/real')).to eq('Here ya go')
    end

    it "passes layout, exposed locals, and app to renderer" do
      subject = Rory::Controller.new(@request, @routing, :scooby)
      subject.expose(:a => 1)
      allow(subject).to receive(:layout).and_return('pretend')
      renderer_options = {
        :layout => 'pretend',
        :locals => { :a => 1 },
        :app => :scooby,
        :base_path => 'script_root'
      }
      allow(Rory::Renderer).to receive(:new).
        with('also/fake', renderer_options).
        and_return(double('Renderer', :render => 'Scamazing!'))
      expect(subject.generate_body_from_template('also/fake')).to eq('Scamazing!')
    end
  end

  describe "#default_content_type" do
    it "returns 'text/html' if not json" do
      allow(subject).to receive(:json_requested?).and_return(false)
      expect(subject.default_content_type).to eq('text/html')
    end

    it "returns 'application/json' if json requested" do
      allow(subject).to receive(:json_requested?).and_return(true)
      expect(subject.default_content_type).to eq('application/json')
    end
  end
end
