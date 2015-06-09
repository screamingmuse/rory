describe Rory::ParameterFilter do

  describe '#initialize' do
    it 'sets the filters' do
      expect(subject.instance_variable_get(:@filters)).to eq []
    end
  end

  describe '#filter' do
    it 'returns params unchanged' do
      unfiltered_params = {"address"=>"11802 MCDONALD ST, Los Angeles, CA 90230",
                "owners"=>[{"first_name"=>"GOLD", "last_name"=>"PATH", "ssn"=>"000-02-9999"}],
                "overrides"=>{"ofac_7403"=>"clear"}}

      expect(subject.filter(unfiltered_params)).to eq unfiltered_params
    end

    it 'returns params filtered by' do
      subject = described_class.new([:ssn])
      unfiltered_params = {"address"=>"11802 MCDONALD ST, Los Angeles, CA 90230",
                "owners"=>[{"first_name"=>"GOLD", "last_name"=>"PATH", "ssn"=>"000-02-9999"}],
                "overrides"=>{"ofac_7403"=>"clear"}}

      filtered_params = {"address"=>"11802 MCDONALD ST, Los Angeles, CA 90230",
                           "owners"=>[{"first_name"=>"GOLD", "last_name"=>"PATH", "ssn"=>"[FILTERED]"}],
                           "overrides"=>{"ofac_7403"=>"clear"}}


      expect(subject.filter(unfiltered_params)).to eq filtered_params
    end

    it 'filters based upon regex' do

      filter_words = []
      filter_words << /ofac*/

      subject = described_class.new(filter_words)

      unfiltered_params = {:address=>"11802 MCDONALD ST, Los Angeles, CA 90230",
                           "owners"=>[{"first_name"=>"GOLD", "last_name"=>"PATH", "ssn"=>"000-02-9999"}],
                           "overrides"=>{"ofac_7403"=>"clear"}}

      filtered_params = {:address=>"11802 MCDONALD ST, Los Angeles, CA 90230",
                           "owners"=>[{"first_name"=>"GOLD", "last_name"=>"PATH", "ssn"=>"000-02-9999"}],
                           "overrides"=>{"ofac_7403"=>"[FILTERED]"}}

      expect(subject.filter(unfiltered_params)).to eq filtered_params
    end
  end
end
