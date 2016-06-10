require "rory/controller/request_logger"

RSpec.describe Rory::Controller::RequestLogger do
  describe "#call" do
    let(:log) { StringIO.new }
    let(:logger) { Logger.new(log) }

    it "log to info" do
      described_class.new(logger: logger).call(action:     "show",
                                               controller: "programs",
                                               params:     { "program_id" => 3 },
                                               path:       "programs/13")

      expect(log.tap(&:rewind).read).to match /INFO -- : request -- {:path=>"programs\/13", :action=>"show", :controller=>"programs", :params=>{"program_id"=>3}}/
    end
  end
end
