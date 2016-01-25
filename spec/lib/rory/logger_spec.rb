require "logger"
require "rory/thread"
require "rory/logger"

describe Rory::Logger do
  subject { described_class.new(string_io) }
  let(:string_io) { StringIO.new }
  let(:result) { string_io.tap(&:rewind).read }

  let(:simple_format) {
    subject.formatter = Proc.new do |severity, _, _, msg, tagged|
      "#{severity} #{tagged} - #{msg}"
    end
  }

  let(:rory_request_id) { "1111-2222" }

  before { Thread.current.inheritable_attributes = Thread.current.inheritable_attributes.merge(:rory_request_id => rory_request_id) }

  context "when tagged is empty" do
    subject { described_class.new(string_io, tagged: []) }
    it "does not tag anything" do
      simple_format
      subject.<< "Hello"
      expect(result).to eq "Hello"
    end
  end

  context "creating custom tags" do
    subject { described_class.new(string_io, tagged: [:custom_tag, :request_id]) }
    it "needs an instance method go along with new tag" do
      def subject.custom_tag
        "Words.."
      end
      simple_format
      subject.<< "Hello"
      expect(result).to eq "custom_tag=Words.. request_id=1111-2222 Hello"
    end
  end

  describe "#<<" do
    it "tags are present with this form" do
      simple_format
      subject.<< "Hello"
      expect(result).to eq "request_id=1111-2222 Hello"
    end
  end

  context "when a tagged values has spaces" do
    let(:rory_request_id) { "1111 2222" }
    it "is quoted" do
      simple_format
      subject.<< "Good Morning"
      expect(result).to eq 'request_id="1111 2222" Good Morning'
    end
  end

  describe "#info" do
    it "severity level is set to INFO" do
      simple_format
      subject.info "Hello"
      expect(result).to eq "INFO request_id=1111-2222 - Hello"
    end
  end

  describe "#formatter" do
    it "define a custom formatting" do
      subject.formatter = Proc.new do |_, _, _, msg, tagged|
        "This is formatted: #{tagged} - #{msg}"
      end
      subject.info "Hello"
      expect(result).to eq "This is formatted: request_id=1111-2222 - Hello"
    end

    it "has default formatting" do
      subject.info "Goodbye"
      expect(result).to match /request_id=1111-2222.*INFO -- : Goodbye\n/
    end
  end

  describe "integration with Rack::CommonLogger" do
    it "only prepends tags" do
      [200, { "REMOTE_ADDR" => "127.0.0.1", "HTTP_VERSION" => "1.1" }, ""]
      Rack::CommonLogger.new(Proc.new { |a| a }, subject).send(:log, { "REMOTE_ADDR" => "127.0.0.1", "HTTP_VERSION" => "1.1", Rack::QUERY_STRING => "abc" }, 200, {}, 1)
      "I, [1111-2222 - 2016-01-20T16:30:52.193516 #5341]  INFO -- : 127.0.0.1 - - [20/Jan/2016:16:30:52 -0800] \" ?abc 1.1\" 200 - 1453336251.1934\n\n"
      expect(result).to match /request_id=1111-2222 127.0.0.1 - - /
    end
  end
end
