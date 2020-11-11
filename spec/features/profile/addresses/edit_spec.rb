require 'rails_helper'

RSpec.describe "As a default user", type: :feature do
  describe "When I visit my list of addresses and click edit address" do
    before(:each) do
      @user = create(:user)
      @home = create(:address, user: @user, nickname: "Home")
      @work = create(:address, user: @user, nickname: "Work")
      @mom = create(:address, user: @user, nickname: "Mom")
      order = create(:order, user: @user, status: 2)
      order_address = OrderAddress.create!(order_id: order.id, address_id: @mom.id)

      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Login"
      click_link "My Addresses"
    end

    it "I can edit an address" do

      within("#address-#{@home.id}") do
        click_on "Edit"
      end

      fill_in :address_nickname, with: "Old Home"
      fill_in :address_name, with: "#{@user.name}"
      fill_in :address_street_address, with: "123 American Dr"
      fill_in :address_city, with: "Denver"
      fill_in :address_state, with: "CO"
      fill_in :address_zip, with: "80203"

      click_on "Update Address"

      expect(current_path).to eq(profile_addresses_path)
      expect(page).to have_content("The address has been updated!")
      within("#address-#{@home.id}") do
        expect(page).to have_content("Old Home")
        expect(page).to have_content("#{@user.name}")
        expect(page).to have_content("123 American Dr")
        expect(page).to have_content("Denver")
        expect(page).to have_content("CO")
        expect(page).to have_content("80203")
      end
    end

    it "I can't edit an address without the necessary data" do
      within("#address-#{@home.id}") do
        click_on "Edit"
      end

      fill_in :address_nickname, with: ""
      fill_in :address_name, with: "#{@user.name}"
      fill_in :address_street_address, with: "2334 Turing Dr."
      fill_in :address_city, with: ""
      fill_in :address_state, with: "CO"
      fill_in :address_zip, with: "80202"

      click_on "Update Address"

      expect(page).to have_content("Nickname can't be blank and City can't be blank")
      expect(find_field(:address_nickname).value).to eq("")
      expect(find_field(:address_name).value).to eq("#{@user.name}")
      expect(find_field(:address_street_address).value).to eq("2334 Turing Dr.")
      expect(find_field(:address_city).value).to eq("")
      expect(find_field(:address_state).value).to eq("CO")
      expect(find_field(:address_zip).value).to eq("80202")
    end

    it "I can't edit an address without the necessary data" do
      visit "/profile/addresses/#{@mom.id}/edit"

      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end
