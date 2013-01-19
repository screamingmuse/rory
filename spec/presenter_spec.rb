require 'spec_helper'

describe Rory::Presenter do
  before :each do
    @request = {
      :route => {
        :presenter => 'test',
        :action => 'letsgo'
      }
    }
  end

  describe "#render" do
    it "returns text of template" do
      presenter = Rory::Presenter.new(@request)
      presenter.render('test/static').should == 'Static content'
    end

    it "evaluates ERB in presenter's context" do
      presenter = Rory::Presenter.new(@request)
      presenter.stub(:word).and_return('hockey')
      presenter.render('test/dynamic').should == 'Word: hockey'
    end
  end

  describe "#redirect" do
    it "delegates to dispatcher from request" do
      @request[:dispatcher] = dispatcher = stub
      dispatcher.should_receive(:redirect).with(:whatever)
      presenter = Rory::Presenter.new(@request)
      presenter.redirect(:whatever)
    end
  end

  describe "#present" do
    it "calls action from route if exists on presenter" do
      presenter = Rory::Presenter.new(@request)
      presenter.stub(:render)
      presenter.should_receive('letsgo')
      presenter.present
    end

    it "doesn't try to call action from route if nonexistent on presenter" do
      presenter = Rory::Presenter.new(@request)
      presenter.stub(:render)
      presenter.stub(:respond_to?).with('letsgo').and_return(false)
      presenter.should_receive('letsgo').never
      presenter.present
    end

    it "just returns a response if @response exists" do
      presenter = Rory::Presenter.new(@request)
      presenter.instance_variable_set(:@response, 'Forced response')
      presenter.present.should == 'Forced response'
    end

    it "renders and returns the default template as a rack response" do
      presenter = Rory::Presenter.new(@request)
      presenter.present.should == [
        200,
        {'Content-type' => 'text/html', 'charset' => 'UTF-8'},
        ["Let's go content"]
      ]
    end

    it "returns previously set @body as a rack response" do
      presenter = Rory::Presenter.new(@request)
      presenter.instance_variable_set(:@body, 'Forced body')
      presenter.should_receive(:render).never
      presenter.present.should == [
        200,
        {'Content-type' => 'text/html', 'charset' => 'UTF-8'},
        ["Forced body"]
      ]
    end
  end
end