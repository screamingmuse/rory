RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
end

shared_examples 'path_generation' do
  describe '#path_to' do
    it 'returns mask from route with given name prepended with root slash' do
      allow(path_generator).to receive(:base_path).and_return(nil)
      expect(path_generator.path_to('awesome_rad')).
        to eq '/this/:path/is/:very_awesome'
    end

    it 'prepends base_path to returned mask' do
      allow(path_generator).to receive(:base_path).and_return('/strawminos')
      expect(path_generator.path_to('awesome_rad')).
        to eq '/strawminos/this/:path/is/:very_awesome'
    end

    it 'substitutes tokens with given fields' do
      allow(path_generator).to receive(:base_path).and_return('/strawminos')
      expect(path_generator.path_to('awesome_rad', :path => 'house', :very_awesome => 352)).
        to eq '/strawminos/this/house/is/352'
    end
  end
end

  