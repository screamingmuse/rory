require 'spec_helper'

describe Rory::Support do
  describe ".camelize" do
    it "camelizes given snake-case string" do
      Rory::Support.camelize('water_under_bridge').should == 'WaterUnderBridge'
    end
  end

  describe '.autoload_file' do
    it 'adds basename of given path to autoload list by default' do
      path = '/fake_root/gas/is/cheap/in/good_old_america.rb'
      Object.should_receive(:autoload).with(:GoodOldAmerica, path)
      Rory::Support.autoload_file(path)
    end
  end
end