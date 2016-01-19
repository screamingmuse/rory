RSpec.describe Rory::RequestId do
  subject { described_class.new(Proc.new {|env|[200, headers, ""] },
                                uuid_prefix:  uuid_prefix,
                                uuid_creator: class_double(SecureRandom, uuid: "1234")) }
  let(:headers) { {} }
  let(:env) { {} }
  let(:uuid_prefix) { nil }

  context "when no external_request_id is set" do
    before { subject.call(env) }

    it "sets env['rory.request_id']" do
      expect(env["rory.request_id"]).to eq "1234"
    end

    it "sets header['X-Request-Id']" do
      expect(headers["X-Request-Id"]).to eq "1234"
    end

    it "sets Thread.current[:rory_request_id]" do
      expect(Thread.current[:rory_request_id]).to eq "1234"
    end

    context "the uuid can be given a prefixed to know where it was created" do
      let(:uuid_prefix) { "app_name" }
      it { expect(Thread.current[:rory_request_id]).to eq "app_name-1234" }
    end
  end

  context "when external_request_id is set" do
    before { subject.call(env) }
    let(:env) { { "HTTP_X_REQUEST_ID" => "4321" } }

    it "sets env['rory.request_id']" do
      expect(env["rory.request_id"]).to eq "4321"
    end

    it "sets header['X-Request-Id']" do
      expect(headers["X-Request-Id"]).to eq "4321"
    end

    it "sets Thread.current[:rory_request_id]" do
      expect(Thread.current[:rory_request_id]).to eq "4321"
    end
  end

  context "use default SecureRandom" do
    subject { described_class.new(Proc.new {|env|[200, headers, ""] },
                                  uuid_prefix:  uuid_prefix).call({}) }
    it "call uuid on SecureRandom" do
      expect(SecureRandom).to receive(:uuid).once
      subject
    end
  end
end
