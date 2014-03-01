describe "Controller" do
  describe "presentation", :type => :feature do
    it 'renders action template' do
      visit '/for_reals/pickles'

      expect(page).to have_text("You've done it again, pickles!")
    end
  end
end