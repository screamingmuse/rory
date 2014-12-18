describe Rory::HashWithDubiousSemantics do
  subject {
    described_class.new(hash)
  }

  context "with a variety of keys" do
    let(:hash) { {
      'violet' => 'invisibility',
      :dash => 'superspeed',
      42 => 'meaning of life...'
    } }

    it 'allows indifferent access for a key that was originally a String' do
      expect( subject[:violet]  ) .to eq( 'invisibility' )
      expect( subject['violet'] ) .to eq( 'invisibility' )
    end

    it 'allows indifferent access for a key that was originally a Symbol' do
      expect( subject[:dash]  ) .to eq( 'superspeed' )
      expect( subject['dash'] ) .to eq( 'superspeed' )
    end

    it 'does not allow indifferent access for a key that was not a string or symbol' do
      expect( subject[42]    ) .to eq( 'meaning of life...' )
      expect( subject[:'42'] ) .to be( nil )
      expect( subject['42']  ) .to be( nil )
    end
  end

  context 'nested hashes' do
    let(:hash) { {
      'violet' => 'invisibility',
      'spam' => {
        'eggs' => 'breakfast'
      }
    } }

    it 'allows indifferent access into sub-hashes' do
      expect( subject[:spam][:eggs]).to eq('breakfast')
      expect( subject['spam']['eggs']).to eq('breakfast')
      expect( subject['spam'][:eggs]).to eq('breakfast')
      expect( subject[:spam]['eggs']).to eq('breakfast')
    end
  end

  context 'assignment' do
    let(:hash) { {} }

    it 'allows assignment by string and symbol' do
      subject[:unicorns] = 'rainbows'
      subject['vampires'] = 'sparkly'

      expect(subject['unicorns']).to eq('rainbows')
      expect(subject[:vampires]).to eq('sparkly')
    end

    it 'wraps hashes on assignment' do
      subject[:srsly] = { 'omg' => { 'wtf' => 'bbq' } }

      expect( subject[:srsly][:omg][:wtf] ).to eq( 'bbq' )
      expect( subject['srsly']['omg']['wtf'] ).to eq( 'bbq' )
    end
  end
end
