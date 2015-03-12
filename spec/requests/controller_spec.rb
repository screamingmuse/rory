describe "Controller" do
  describe "presentation", :type => :feature do
    it 'renders default action template' do
      visit '/for_reals/pickles'

      expect(page).to have_text("You've done it again, pickles!")
      expect(page.status_code).to eq 200
      expect(page.response_headers['Content-Type']).to eq('text/html')
    end

    it 'renders json' do
      visit '/for_reals/switching.json'

      expect(page).to have_text({ :a => 1 }.to_json)
      expect(page.status_code).to eq 200
      expect(page.response_headers['Content-Type']).to eq('application/json')
    end

    it 'renders custom template' do
      visit '/for_reals/switching'

      expect(page).to have_text("Oh, a secret!")
      expect(page.status_code).to eq 404
      expect(page.response_headers['Content-Type']).to eq('text/html')
    end
  end
end