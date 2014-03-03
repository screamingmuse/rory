require 'spec_helper'

describe Rory do
  describe '.application' do
    it 'is by default set to the Rory::Application instance' do
      Rory.application.should == Fixture::Application.instance
    end
  end

  describe '.root' do
    it 'returns root of application' do
      Rory.root.should == Rory.application.root
    end
  end
end