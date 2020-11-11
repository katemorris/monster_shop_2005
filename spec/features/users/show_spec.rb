require 'rails_helper'

describe 'As a registered user' do
  describe "when I login as a user" do
    before :each do
      @user = create(:user)
      visit login_path

      fill_in :email, with: @user.email
      fill_in :password, with: @user.password

      click_button "Login"
    end

    it "I am taken to my profile " do
      expect(current_path).to eq("/profile")
    end

    it "There are links perform actions." do
      expect(page).to have_link("Edit Password")
      expect(page).to have_link("Edit Profile")

      click_on "My Orders"
      expect(current_path).to eq('/profile/orders')
    end

    it "There is a link that will take me to my addresses" do
      click_on "My Addresses"
      expect(current_path).to eq(profile_addresses_path)
    end
  end
end
