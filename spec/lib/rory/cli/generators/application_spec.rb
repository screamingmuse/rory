require "rory/cli"

describe Rory::CLI::Generators::Application do
  let(:options) { {} }
  let(:args) { ["an app"] }
  subject { described_class.new(args, options, :destination_root => sandbox_directory) }

  after(:each) do
    FileUtils.rm_rf sandbox_directory
  end

  context "with default options" do
    it "generates a new application directory with no optional files" do
      capture_output { subject.invoke_all }
      expect(sandbox_directory.join("an_app")).to be_a_directory
      expect(sandbox_directory.join("an_app", "config.ru")).to be_a_file
      expect(sandbox_directory.join("an_app", ".rspec")).not_to be_a_file
    end

    it "logs the output" do
      result = capture_output { subject.invoke_all }
      expect(result).to include("create  an_app")
    end
  end

  context "with default options" do
    let(:options) { { rspec: true } }

    it "adds rspec files" do
      capture_output { subject.invoke_all }
      expect(sandbox_directory.join("an_app", ".rspec")).to be_a_file
      expect(sandbox_directory.join("an_app", "spec", "spec_helper.rb")).to be_a_file
    end
  end
end