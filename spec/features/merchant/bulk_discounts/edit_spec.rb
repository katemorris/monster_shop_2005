require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "When I visit the bulk discounts index page" do
    before(:each) do
      @brian = Merchant.create(name: "Brian's Dog Shop", address: '125 Doggo St.', city: 'Denver', state: 'CO', zip: 80210)
      user = create(:user, role: 1, merchant_id: @brian.id)
      visit login_path
      fill_in :email, with: user.email
      fill_in :password, with: 'password'
      click_button "Login"

      @discount_10 = BulkDiscount.create!(name: "10 for 10", percent_off: 10, min_amount: 10, merchant_id: @brian.id)
      @discount_5 = BulkDiscount.create!(name: "5 for 5", percent_off: 5, min_amount: 5, merchant_id: @brian.id)
    end

    it 'I click on the link to edit a bulk discount and find a form with the details of the discount' do
      visit merchant_bulk_discounts_path

      within("#discount-#{@discount_10.id}") do
        click_on "Edit"
      end

      expect(current_path).to eq(edit_merchant_bulk_discount_path(@discount_10))
      expect(find_field(:bulk_discount_name).value).to eq(@discount_10.name)
      expect(find_field(:bulk_discount_percent_off).value).to eq(@discount_10.percent_off.to_s)
      expect(find_field(:bulk_discount_min_amount).value).to eq(@discount_10.min_amount.to_s)
    end

    it "I can edit the discount's details" do
      visit merchant_bulk_discounts_path

      within("#discount-#{@discount_10.id}") do
        click_on "Edit"
      end

      fill_in :bulk_discount_percent_off, with: 25
      click_on "Update Bulk discount"

      expect(current_path).to eq(merchant_bulk_discounts_path)
      expect(page).to have_content("Discount has been updated.")
      within("#discount-#{@discount_10.id}") do
        expect(page).to have_content(@discount_10.name)
        expect(page).to have_content("25.0%")
      end
    end

    it "I can't edit a discount without all data" do
      visit edit_merchant_bulk_discount_path(@discount_5)

      fill_in :bulk_discount_name, with: ""
      fill_in :bulk_discount_percent_off, with: ""
      fill_in :bulk_discount_min_amount, with: ""

      click_on "Update Bulk discount"

      expect(page).to have_content("Name can't be blank, Percent off can't be blank, Percent off is not a number, Min amount can't be blank, and Min amount is not a number")
    end

    it "I can't edit with incorrect data" do
      visit edit_merchant_bulk_discount_path(@discount_5)

      fill_in :bulk_discount_min_amount, with: -1

      click_on "Update Bulk discount"

      expect(page).to have_content("Min amount must be greater than 0")
    end
  end
end
