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

  describe '.autoload_all_files_in_directory' do
    it 'autoloads all files from given path' do
      Dir.stub(:[]).with(Pathname.new('spinach').join('**', '*.rb')).
        and_return(["pumpkins", "some_guy_dressed_as_liberace"])
      Rory::Support.should_receive(:autoload_file).with("pumpkins")
      Rory::Support.should_receive(:autoload_file).with("some_guy_dressed_as_liberace")
      Rory::Support.autoload_all_files_in_directory('spinach')
    end
  end
end