require 'rails_helper'

RSpec.describe "As a merchant" do
  describe "When I visit the merchant dashboard" do
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

    it 'I see a link to view my bulk discounts' do
      visit "/merchant"

      expect(page).to have_link("Bulk Discounts")
    end

    it 'I can click on that link and see my current discounts' do
      visit "/merchant"

      click_link "Bulk Discounts"

      expect(page).to have_link("Add Bulk Discount")

      within("#discount-#{@discount_10.id}") do
        expect(page).to have_content(@discount_10.name)
        expect(page).to have_link('Edit')
        expect(page).to have_link('Delete')
      end

      within("#discount-#{@discount_5.id}") do
        expect(page).to have_content(@discount_5.name)
        expect(page).to have_link('Edit')
        expect(page).to have_link('Delete')
      end
    end

    it "I don't see other merchant's discounts" do
      competitor = Merchant.create(name: "Competitor", address: '19584 Whatever Ln', city: 'Denver', state: 'CO', zip: 80210)
      not_my_discount = BulkDiscount.create!(name: "Bad Idea", percent_off: 100, min_amount: 1, merchant_id: competitor.id)

      visit merchant_bulk_discounts_path
      expect(page).to have_content(@discount_5.name)
      expect(page).to_not have_content(not_my_discount.name)
    end

    it "I can delete a discount." do
      visit merchant_bulk_discounts_path

      within("#discount-#{@discount_5.id}") do
        click_on "Delete"
      end

      expect(page).to have_content("Discount has been deleted.")
      expect(current_path).to eq(merchant_bulk_discounts_path)
    end
  end
end
