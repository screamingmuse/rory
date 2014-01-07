require 'spec_helper'

describe Rory::Controller do
  before :each do
    @request = {
      :route => {
        :controller => 'test',
        :action => 'letsgo'
      }
    }

    @request.stub(:params => {})
  end

  describe '#layout' do
    it 'defaults to nil' do
      controller = Rory::Controller.new(@request)
      controller.layout.should be_nil
    end
  end

  describe "#render" do
    it "returns text of template" do
      controller = Rory::Controller.new(@request)
      controller.render('test/static').should == 'Static content'
    end

    it "returns text of template in controller's layout" do
      controller = Rory::Controller.new(@request)
      controller.stub(:layout => 'surround')
      controller.render('test/static').should == 'Surrounding Static content is fun'
    end

    it "handles symbolized layout name" do
      controller = Rory::Controller.new(@request)
      controller.stub(:layout => :surround)
      controller.render('test/static').should == 'Surrounding Static content is fun'
    end

    it "returns text of template in given layout from options" do
      controller = Rory::Controller.new(@request)
      controller.render('test/static', :layout => 'surround').should == 'Surrounding Static content is fun'
    end

    it "evaluates ERB in controller's context" do
      controller = Rory::Controller.new(@request)
      controller.stub(:word).and_return('hockey')
      controller.render('test/dynamic').should == 'Word: hockey'
    end
  end

  describe "#redirect" do
    it "delegates to dispatcher from request" do
      @request[:dispatcher] = dispatcher = stub
      dispatcher.should_receive(:redirect).with(:whatever)
      controller = Rory::Controller.new(@request)
      controller.redirect(:whatever)
    end
  end

  describe "#render_not_found" do
    it "delegates to dispatcher from request" do
      @request[:dispatcher] = dispatcher = stub
      dispatcher.should_receive(:render_not_found)
      controller = Rory::Controller.new(@request)
      controller.render_not_found
    end
  end

  describe "#present" do
    it "calls action from route if exists on controller" do
      controller = Rory::Controller.new(@request)
      controller.stub(:render)
      controller.should_receive('letsgo')
      controller.present
    end

    it "doesn't try to call action from route if nonexistent on controller" do
      controller = Rory::Controller.new(@request)
      controller.stub(:render)
      controller.stub(:respond_to?).with('letsgo').and_return(false)
      controller.should_receive('letsgo').never
      controller.present
    end

    it "just returns a response if @response exists" do
      controller = Rory::Controller.new(@request)
      controller.instance_variable_set(:@response, 'Forced response')
      controller.present.should == 'Forced response'
    end

    it "renders and returns the default template as a rack response" do
      controller = Rory::Controller.new(@request)
      controller.present.should == [
        200,
        {'Content-type' => 'text/html', 'charset' => 'UTF-8'},
        ["Let's go content"]
      ]
    end

    it "returns previously set @body as a rack response" do
      controller = Rory::Controller.new(@request)
      controller.instance_variable_set(:@body, 'Forced body')
      controller.should_receive(:render).never
      controller.present.should == [
        200,
        {'Content-type' => 'text/html', 'charset' => 'UTF-8'},
        ["Forced body"]
      ]
    end
  end

  describe '#view_path' do
    it 'returns path to template from context root' do
      fake_context = double('Context', :root => 'marbles')
      controller = Rory::Controller.new(@request, fake_context)
      controller.view_path('goose').should == File.expand_path(File.join('views', 'goose.html.erb'), 'marbles')
    end

    it 'uses Rory.root if no context' do
      controller = Rory::Controller.new(@request)
      controller.view_path('goose').should == File.join(Rory.root, 'views', 'goose.html.erb')
    end
  end
end
