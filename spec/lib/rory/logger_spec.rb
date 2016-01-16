require "logger"
require "rory/logger"

describe Rory::Logger do
  subject { described_class.new(string_io) }
  let(:string_io) { StringIO.new }
  let(:result) { string_io.tap(&:rewind).read }

  let(:simple_format) {
    subject.formatter = Proc.new do |severity, _, _, msg, request_id|
      "#{severity} #{request_id} - #{msg}"
    end
  }

  before { Thread.current[:rory_request_id] = "1111-2222" }

  describe "#write" do
    it "severity level is set to INFO" do
      simple_format
      subject.write "Hello"
      expect(result).to eq "INFO 1111-2222 - Hello"
    end
  end

  describe "#info" do
    it "severity level is set to INFO" do
      simple_format
      subject.info "Hello"
      expect(result).to eq "INFO 1111-2222 - Hello"
    end
  end

  describe "#formatter" do
    it "define a custom formatting" do
      subject.formatter = Proc.new do |_, _, _, msg, request_id|
        "This is formatted: #{request_id} - #{msg}"
      end
      subject.info "Hello"
      expect(result).to eq "This is formatted: 1111-2222 - Hello"
    end

    it "has default formatting" do
      subject.info "Goodbye"
      expect(result).to match /\[1111-2222.*INFO -- : Goodbye\n/
    end
  end
end
