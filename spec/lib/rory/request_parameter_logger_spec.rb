describe Rory::RequestParameterLogger do

  let(:logger) { double(:write) }
  let(:app) { double(:call) }
  subject { described_class.new(app, logger, :filters => :filters) }

  describe '#initialize' do
    it 'returns a new RequestParameterLogger' do
      expect(subject).to be_an_instance_of(Rory::RequestParameterLogger)
    end

    it 'returns a new RequestParameterLogger with parameters' do
      expect(subject.instance_variable_get(:@app)).to eq(app)
      expect(subject.instance_variable_get(:@logger)).to eq(logger)
      expect(subject.instance_variable_get(:@filters)).to eq(:filters)
    end

    it 'defaults filters to empty array' do
      no_filter_logger = described_class.new(app, logger)
      expect(no_filter_logger.instance_variable_get(:@filters)).to eq([])
    end
  end

  describe '#log_request' do

    context 'when logger responds to write' do
      it 'writes the request to the logger' do
        allow(subject).to receive(:request_signature).and_return('request_signature')
        allow(subject).to receive(:filtered_params).and_return('filtered_params')
        expect(logger).to receive(:write).exactly(2).times
        subject.send(:log_request)
      end
    end

    context 'when logger does not respond to write' do
      let(:logger) { double(:info) }
      it 'writes the request to the logger' do
        allow(subject).to receive(:request_signature).and_return('request_signature')
        allow(subject).to receive(:filtered_params).and_return('filtered_params')
        expect(logger).to receive(:info).exactly(2).times
        subject.send(:log_request)
      end
    end
  end

  describe '#logger' do
    it 'returns @logger' do
      expect(subject.send(:logger)).to eq(logger)
    end

    it 'returns rack.errors ' do
      subject = described_class.new(:app)
      subject.instance_variable_set(:@env, {'rack.errors' => 'cocoa'})
      expect(subject.send(:logger)).to eq('cocoa')
    end
  end

  describe '#filtered_params' do
    it 'filters the params' do
      expect(Rory::ParameterFilter).to receive(:new).and_return(double(:filter => nil))
      expect(subject).to receive(:unfiltered_params)
      subject.send(:filtered_params)
    end
  end

  describe '#unfiltered_params' do
    it 'returns unfiltered params' do
      expect(Rack::Request).to receive(:new).and_return(double(:params => nil))
      subject.send(:unfiltered_params)
    end
  end

  describe '#request_signature' do
    it 'returns a request signature formatted string' do
      env = {
        'REQUEST_METHOD' => "POST",
        'PATH_INFO' => "/mushy_mushy",
        'REMOTE_ADDR' => "127.0.0.1"
      }

      allow(Time).to receive(:now).and_return("2015-06-08 15:16:42 -0700")
      subject.instance_variable_set(:@env, env)
      expect(subject.send(:request_signature)).to eq('Started POST "/mushy_mushy" for 127.0.0.1 at 2015-06-08 15:16:42 -0700')
    end
  end


  describe '#call' do
    it 'writes the request and parameters to the log file' do
      env = {
        'rack.input' => double(:rewind => nil)
      }
      expect(app).to receive(:call).with(env)
      expect(subject).to receive(:log_request)

      subject.call(env)
      expect(subject.instance_variable_get(:@env)).to eq(env)
    end
  end
end