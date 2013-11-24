require 'spec_helper'

describe Rory do
  describe '.autoload_paths' do
    after(:each) do
      Rory.instance_variable_set(:@autoload_paths, nil)
    end

    it 'includes models, controllers, and helpers by default' do
      Rory.autoload_paths.should == ['models', 'controllers', 'helpers']
    end

    it 'accepts new paths' do
      Rory.autoload_paths << 'chocolates'
      Rory.autoload_paths.should == ['models', 'controllers', 'helpers', 'chocolates']
    end
  end

  describe '.autoload_all_files' do
    it 'autoloads from autoload_paths' do
      Rory.stub(:autoload_paths).and_return(['goats', 'rhubarbs'])
      [:goats, :rhubarbs].each do |folder|
        Dir.stub(:[]).with(File.join(Rory.root, "#{folder}", '*.rb')).
          and_return(["#{folder}1", "#{folder}2"])
        Rory.should_receive(:autoload_file).with("#{folder}1")
        Rory.should_receive(:autoload_file).with("#{folder}2")
      end
      Rory.autoload_all_files
    end
  end

  describe '.autoload_file' do
    before(:each) do
      Rory.stub(:root).and_return('/fake_root')
    end

    it 'adds basename of given path to autoload list by default' do
      path = '/fake_root/gas/is/cheap/in/good_old_america.rb'
      Object.should_receive(:autoload).with(:GoodOldAmerica, path)
      Rory.autoload_file(path)
    end
  end
end