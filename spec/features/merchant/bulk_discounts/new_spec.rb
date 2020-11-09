require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "When I visit the bulk discounts index page" do
    before(:each) do
      @brian = Merchant.create(
        name: "Brian's Dog Shop",
        address: '125 Doggo St.',
        city: 'Denver',
        state: 'CO',
        zip: 80210
      )
      user = create(:user, role: 1, merchant_id: @brian.id)
      visit login_path
      fill_in :email, with: user.email
      fill_in :password, with: 'password'
      click_button "Login"

      @discount_10 = BulkDiscount.create!(
        name: "10 for 10",
        percent_off: 10,
        min_amount: 10,
        merchant_id: @brian.id
      )
      @discount_5 = BulkDiscount.create!(
        name: "5 for 5",
        percent_off: 5,
        min_amount: 5,
        merchant_id: @brian.id
      )
    end

    it 'I click on the link to add a new discount and can add one.' do
      visit merchant_bulk_discounts_path

      click_link "Add Bulk Discount"

      fill_in :bulk_discount_name, with: "New Year Deal"
      fill_in :bulk_discount_percent_off, with: 25
      fill_in :bulk_discount_min_amount, with: 10

      click_on "Create Bulk discount"

      expect(page).to have_content("Discount created successfully!")

      discount = BulkDiscount.last
      expect(discount.name).to eq("New Year Deal")
      expect(discount.percent_off).to eq(25)
      expect(discount.min_amount).to eq(10)
    end

    it "I can't add a discount without all data" do
      visit merchant_bulk_discounts_path

      click_link "Add Bulk Discount"

      fill_in :bulk_discount_name, with: ""
      fill_in :bulk_discount_percent_off, with: 25
      fill_in :bulk_discount_min_amount, with: 10

      click_on "Create Bulk discount"

      expect(page).to have_content("Name can't be blank")
    end

    it "I can't add a discount with less than 1 percent off" do
      visit new_merchant_bulk_discount_path

      fill_in :bulk_discount_name, with: "New Year Deal"
      fill_in :bulk_discount_percent_off, with: 0
      fill_in :bulk_discount_min_amount, with: 10

      click_on "Create Bulk discount"

      expect(page).to have_content("Percent off must be greater than 0")

      fill_in :bulk_discount_percent_off, with: -1
      click_on "Create Bulk discount"
      expect(page).to have_content("Percent off must be greater than 0")

      fill_in :bulk_discount_percent_off, with: 2
      click_on "Create Bulk discount"
      expect(page).to have_content("Discount created successfully!")
    end

    it "I can't add a discount with less than 1 minimum amount" do
      visit new_merchant_bulk_discount_path

      fill_in :bulk_discount_name, with: "New Year Deal"
      fill_in :bulk_discount_percent_off, with: 25
      fill_in :bulk_discount_min_amount, with: 0

      click_on "Create Bulk discount"

      expect(page).to have_content("Min amount must be greater than 0")

      fill_in :bulk_discount_min_amount, with: -1
      click_on "Create Bulk discount"
      expect(page).to have_content("Min amount must be greater than 0")

      fill_in :bulk_discount_min_amount, with: 2
      click_on "Create Bulk discount"
      expect(page).to have_content("Discount created successfully!")
    end
  end
end
