require 'spec_helper'

describe Rory::Support do
  describe ".camelize" do
    it "camelizes given snake-case string" do
      Rory::Support.camelize('water_under_bridge').should == 'WaterUnderBridge'
    end
  end

  describe '.require_all_files_in_directory' do
    it 'requires all files from given path' do
      Dir.stub(:[]).with(Pathname.new('spinach').join('**', '*.rb')).
        and_return(["pumpkins", "some_guy_dressed_as_liberace"])
      Rory::Support.should_receive(:require).with("pumpkins")
      Rory::Support.should_receive(:require).with("some_guy_dressed_as_liberace")
      Rory::Support.require_all_files_in_directory('spinach')
    end
  end
end