describe Rory::Renderer::Context do
  describe "#render" do
    it "returns sub-renderer output" do
      renderer_context = Rory::Renderer::Context.new({
        :app => :an_app,
        :base_url => 'yoyo'
      })
      passed_renderer_options = {
        :layout => false, :app => :an_app, :base_url => 'yoyo'
      }
      allow(Rory::Renderer).to receive(:new).
        with('not/real', passed_renderer_options).
        and_return(double('Renderer', :render => 'Here ya go'))
      renderer_context.render('not/real').should == 'Here ya go'
    end

    it "does not pass locals or layout to sub-renderer" do
      renderer_context = Rory::Renderer::Context.new({
        :locals => { :thing => :great },
        :app => :an_app,
        :base_url => 'yoyo',
        :layout => 'groooovy'
      })
      passed_renderer_options = {
        :layout => false, :app => :an_app, :base_url => 'yoyo'
      }
      allow(Rory::Renderer).to receive(:new).
        with('also/fake', passed_renderer_options).
        and_return(double('Renderer', :render => 'Scamazing!'))
      renderer_context.render('also/fake').should == 'Scamazing!'
    end
  end
end
