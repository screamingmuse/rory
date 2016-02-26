RSpec.describe Rory::Initializers do

  describe "#unshift" do
    it "adds an item to the front" do
      subject.unshift("test.1unshift") {}
      subject.unshift("test.2unshift") {}
      expect(subject.initializers.map(&:name)).to eq %w(test.2unshift test.1unshift)
    end
  end

  describe "#insert" do
    it "adds an item before another" do
      subject.add("test.1insert") {}
      subject.insert("test.1insert", "test.2insert") {}
      expect(subject.initializers.map(&:name)).to eq %w(test.2insert test.1insert)
    end
  end

  describe "#insert_before" do
    it "adds an item before another" do
      subject.add("test.1insert_before") {}
      subject.insert_before("test.1insert_before", "test.2insert_before") {}
      expect(subject.initializers.map(&:name)).to eq %w(test.2insert_before test.1insert_before)
    end
  end

  describe "#insert_after" do
    it "adds an item at certain point after a given initializer" do
      subject.add("test.1insert_after") {}
      subject.add("test.2insert_after") {}
      subject.insert_after("test.1insert_after", "test.3insert_after") {}
      expect(subject.initializers.map(&:name)).to eq %w(test.1insert_after test.3insert_after test.2insert_after)
    end
  end

  describe "#delete" do
    it "removes a given initializer from loading" do
      subject.add("test.delete") {}
      subject.delete("test.delete")
      expect(subject.initializers.map(&:name)).to eq []
    end
  end

  describe "#add" do
    it "push an item on the list to be loaded" do
      subject.add("test.1add") {}
      subject.add("test.2add") {}
      expect(subject.initializers.map(&:name)).to eq %w(test.1add test.2add)
    end

    context "when two initializers have the same name" do
      it "raises an error" do
        subject.add("same_name_test") {}
        expect{subject.add("same_name_test") {}}.to raise_error(/Initializer name: 'same_name_test' is already used./)
      end
    end
  end

  describe "#run" do
    it "runs the initializers when given an app" do
      probe = :block_not_run
      subject.add("test.1add") { |app| probe = app }
      subject.run(:this_is_the_app)
      expect(probe).to eq :this_is_the_app
    end
  end

  context "delegated array methods" do
    [:each, :clear, :size, :last, :first].each do |meth|
      it "##{meth}" do
        expect(subject.initializers).to receive(meth)
        subject.public_send(meth)
      end
    end
  end
end

