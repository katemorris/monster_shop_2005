require 'rails_helper'

RSpec.describe "As a default user", type: :feature do
  describe "When I visit my list of addresses and click add new address" do
    before(:each) do
      @user = create(:user)
      @home = create(:address, user: @user, nickname: "Home")

      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Login"
      click_link "My Addresses"
      click_link "Add New Address"
    end

    it "I can add a new address" do
      fill_in :address_nickname, with: "School"
      fill_in :address_name, with: "#{@user.name}"
      fill_in :address_street_address, with: "2334 Turing Dr."
      fill_in :address_city, with: "Denver"
      fill_in :address_state, with: "CO"
      fill_in :address_zip, with: "80202"

      click_on "Create Address"
      address = Address.last
      expect(current_path).to eq(profile_addresses_path)
      expect(page).to have_content("School has been added!")
      within("#address-#{address.id}") do
        expect(page).to have_content(address.nickname)
        expect(page).to have_content(address.name)
        expect(page).to have_content(address.street_address)
        expect(page).to have_content(address.city)
        expect(page).to have_content(address.state)
        expect(page).to have_content(address.zip)
      end
    end

    it "I can't add a new address without the necessary data" do
      fill_in :address_nickname, with: ""
      fill_in :address_name, with: "#{@user.name}"
      fill_in :address_street_address, with: "2334 Turing Dr."
      fill_in :address_city, with: ""
      fill_in :address_state, with: "CO"
      fill_in :address_zip, with: "80202"

      click_on "Create Address"

      expect(page).to have_content("Nickname can't be blank and City can't be blank")
      expect(find_field(:address_nickname).value).to eq("")
      expect(find_field(:address_name).value).to eq("#{@user.name}")
      expect(find_field(:address_street_address).value).to eq("2334 Turing Dr.")
      expect(find_field(:address_city).value).to eq("")
      expect(find_field(:address_state).value).to eq("CO")
      expect(find_field(:address_zip).value).to eq("80202")
    end
  end
end
