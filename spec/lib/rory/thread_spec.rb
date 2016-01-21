require "thread"
require "rory/thread"

RSpec.describe Thread do
  describe ".new" do
    before { Thread.current.inheritable_attributes[:rory_request_id] = SecureRandom.uuid }
    it "when creating a new thread it copies inheritable_attributes" do

      thread = Thread.new {
        Thread.current.inheritable_attributes
      }
      thread.join
      expect(thread.value).to eq Thread.current.inheritable_attributes
    end
  end

  describe ".inheritable_attributes" do
    it "defaults to a Hash" do
      expect(Thread.current.inheritable_attributes.is_a?(Hash)).to eq true
    end

    it "defaults to a Hash" do
      expect(Thread.current.inheritable_attributes.is_a?(Hash)).to eq true
    end
  end
end
