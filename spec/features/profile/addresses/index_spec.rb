require 'rails_helper'

RSpec.describe "As a default user", type: :feature do
  describe "When I visit my list of addresses" do
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

    it "I can see all my addresses" do
      within("#address-#{@home.id}") do
        expect(page).to have_content(@home.nickname)
        expect(page).to have_content(@home.name)
        expect(page).to have_content(@home.street_address)
        expect(page).to have_content(@home.city)
        expect(page).to have_content(@home.state)
        expect(page).to have_content(@home.zip)
      end

      within("#address-#{@work.id}") do
        expect(page).to have_content(@work.nickname)
        expect(page).to have_content(@work.name)
        expect(page).to have_content(@work.street_address)
        expect(page).to have_content(@work.city)
        expect(page).to have_content(@work.state)
        expect(page).to have_content(@work.zip)
      end

      within("#address-#{@mom.id}") do
        expect(page).to have_content(@mom.nickname)
        expect(page).to have_content(@mom.name)
        expect(page).to have_content(@mom.street_address)
        expect(page).to have_content(@mom.city)
        expect(page).to have_content(@mom.state)
        expect(page).to have_content(@mom.zip)
      end
    end

    it "I can't see others addresses" do
      susan = create(:user)
      not_mine = create(:address, user: susan)

      expect(page).to_not have_content(not_mine.nickname)
      expect(page).to_not have_content(not_mine.name)
      expect(page).to_not have_content(not_mine.street_address)
      expect(page).to_not have_content(not_mine.city)
      expect(page).to_not have_content(not_mine.state)
      expect(page).to_not have_content(not_mine.zip)
    end

    it "I can find links to add, edit or delete an address" do
      expect(page).to have_link("Add New Address")

      within("#address-#{@home.id}") do
        expect(page).to have_link("Edit")
        expect(page).to have_link("Delete")
      end

      within("#address-#{@work.id}") do
        expect(page).to have_link("Edit")
        expect(page).to have_link("Delete")
      end
    end

    it "I can delete an address" do
      within("#address-#{@work.id}") do
        click_link("Delete")
      end

      expect(current_path).to eq(profile_addresses_path)
      expect(page).to_not have_content(@work.street_address)
      expect(page).to_not have_content(@work.nickname)
      expect(page).to_not have_content(@work.zip)
    end

    it "I can't delete an address that has a shipped order" do
      within("#address-#{@mom.id}") do
        expect(page).to_not have_link("Edit")
        expect(page).to_not have_link("Delete")
        expect(page).to have_content("This address cannot be edited.")
      end
    end
  end
end
