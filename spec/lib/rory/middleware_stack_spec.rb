RSpec.describe Rory::MiddlewareStack do

  let(:middleware_order) { subject.middlewares.map(&:klass).map(&:name) }

  describe "#unshift" do
    it "adds an item to the front" do
      subject.unshift(double(name: "unshift1")) {}
      subject.unshift(double(name: "unshift2"), 1, 2)

      expect(middleware_order).to eq %w(unshift2 unshift1)
    end
  end

  describe "#insert" do
    it "adds an item to the end" do
      insert1 = (double(name: "insert1"))
      subject.use(insert1) {}
      subject.insert(insert1, double(name: "insert2"), 1, 2)

      expect(middleware_order).to eq %w(insert2 insert1)
    end
  end

  describe "#insert_before" do
    it "adds an item to the end" do
      insert1 = (double(name: "insert_before1"))
      subject.use(insert1) {}
      subject.insert(insert1, double(name: "insert_before2"), 1, 2)

      expect(middleware_order).to eq %w(insert_before2 insert_before1)
    end
  end

  describe "#insert_after" do
    it "adds an item at certain point after a given middleware" do
      insert_after1 = double(name: "test.1insert_after")
      subject.use(insert_after1) {}
      subject.use(double(name: "test.2insert_after")) {}
      subject.insert_after(insert_after1, double(name: "test.3insert_after")) {}
      expect(middleware_order).to eq %w(test.1insert_after test.3insert_after test.2insert_after)
    end
  end

  describe "#insert_after.or_add" do
    it "adds an item at certain point after a given middleware" do
      insert_after1 = double(name: "test.1insert_after")
      subject.use(insert_after1) {}
      subject.use(double(name: "test.2insert_after")) {}
      subject.insert_after.or_add(insert_after1, double(name: "test.3insert_after")) {}
      expect(middleware_order).to eq %w(test.1insert_after test.3insert_after test.2insert_after)
    end

    it "push an item on the list to be loaded when middleware not found" do
      insert_after1 = double(name: "test.1insert_after")
      subject.use(double(name: "test.2insert_after")) {}
      subject.insert_after.or_add(insert_after1, double(name: "test.3insert_after")) {}
      expect(middleware_order).to eq %w(test.2insert_after test.1insert_after)
    end
  end

  describe "#delete" do
    it "removes a given middleware from loading" do
      test_delete = double(name: "delete")
      subject.use(test_delete)
      subject.delete(test_delete)
      expect(middleware_order).to eq []
    end
  end

  describe "#use" do
    it "push an item on the list to be loaded" do
      subject.use(double(name: "use1")) {}
      subject.use(double(name: "use2"), 1, 2)

      expect(middleware_order).to eq %w(use1 use2)
    end

    it "arguments will be saved" do
      subject.use(double(name: "use1")) {}
      subject.use(double(name: "use2"), 1, 2)

      expect(subject.middlewares.map(&:args)).to eq [[], [1, 2]]
    end

    it "blocks will be saved" do
      probe = :block_not_called
      subject.use(double(name: "use1")) {probe = :block_called}
      subject.use(double(name: "use2"), 1, 2)
      subject.middlewares.map(&:block).compact.map(&:call)
      expect(probe).to eq :block_called
    end
  end

  context "delegated array methods" do
    [:each, :clear, :size, :last, :first].each do |meth|
      it "##{meth}" do
        expect(subject.middlewares).to receive(meth)
        subject.public_send(meth)
      end
    end
  end
end

