require 'rails_helper'

RSpec.describe 'Cart show' do
  describe "When I buy in bulk, I can recieve a discount." do
    before(:each) do
      @mike = Merchant.create(
        name: "Mike's Print Shop",
        address: '123 Paper Rd.',
        city: 'Denver',
        state: 'CO',
        zip: 80203
      )
      @meg = Merchant.create(
        name: "Meg's Bike Shop",
        address: '123 Bike Rd.',
        city: 'Denver',
        state: 'CO',
        zip: 80203
      )

      @tire = @meg.items.create(
        name: "Gatorskins",
        description: "They'll never pop!",
        price: 100,
        image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588",
        inventory: 12
      )
      @paper = @mike.items.create(
        name: "Lined Paper",
        description: "Great for writing on!",
        price: 20,
        image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png",
        inventory: 25
      )
      @pencil = @mike.items.create(
        name: "Yellow Pencil",
        description: "You can write on paper with it!",
        price: 2,
        image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg",
        inventory: 100
      )

      @discount_10 = BulkDiscount.create!(
        name: "10 for 10",
        percent_off: 10,
        min_amount: 10,
        merchant_id: @mike.id
      )

      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"
      visit "/cart"
      click_on "+"
      click_on "+"
      click_on "+"
      click_on "+"
      click_on "+"
      click_on "+"
      click_on "+"
      click_on "+"
    end

    it "When I add enough items, the discount renders in the cart." do
      expect(page).to_not have_content("Discounts applied!")
      expect(page).to have_content("Total: $18.00")
      expect(page).to have_content("9")
      expect(page).to have_content("$2.00")

      click_on "+"

      expect(page).to have_content("Discounts applied!")
      expect(page).to have_content("Total: $18.00")
      expect(page).to_not have_content("$20.00")
      expect(page).to have_content("10")
      expect(page).to have_content("$1.80")
    end

    it "When #items drops below the threshold, the discount is removed." do
      expect(page).to have_content("$2.00")

      click_on "+"

      expect(page).to have_content("10")
      expect(page).to have_content("$1.80")

      click_on "-"

      expect(page).to have_content("Total: $18.00")
      expect(page).to have_content("9")
      expect(page).to have_content("$2.00")
      expect(page).to_not have_content("$1.80")
    end

    it "The discount only applies to the item that meets the min amount." do
      click_on "+"

      within "#cart-item-#{@pencil.id}" do
        expect(page).to have_content("$1.80")
      end

      visit "/items/#{@paper.id}"
      click_on "Add To Cart"

      visit '/cart'

      within "#cart-item-#{@paper.id}" do
        expect(page).to have_content("$#{@paper.price}")
      end
    end

    it "The discount applies to two items if they both meet the threshold" do
      discount_5 = BulkDiscount.create!(
        name: "5 for 5",
        percent_off: 5,
        min_amount: 5,
        merchant_id: @mike.id
      )

      within "#cart-item-#{@pencil.id}" do
        click_on "+"
        expect(page).to have_content("$1.80")
      end

      visit "/items/#{@paper.id}"
      click_on "Add To Cart"

      visit '/cart'

      within "#cart-item-#{@pencil.id}" do
        expect(page).to have_content("$1.80")
      end

      within "#cart-item-#{@paper.id}" do
        expect(page).to have_content("$#{@paper.price}")
        click_on "+"
        click_on "+"
        click_on "+"
        click_on "+"
        expect(page).to have_content("$19.00")
      end
    end

    it "The discount doesn't apply to items from other merchants." do
      discount_2 = BulkDiscount.create!(
        name: "2 for 2",
        percent_off: 2,
        min_amount: 2,
        merchant_id: @meg.id
      )

      visit "/items/#{@paper.id}"
      click_on "Add To Cart"

      visit '/cart'

      within "#cart-item-#{@pencil.id}" do
        expect(page).to have_content("$2.00")
      end

      within "#cart-item-#{@paper.id}" do
        expect(page).to have_content("$#{@paper.price}")
        click_on "+"
        expect(page).to have_content("2")
        expect(page).to have_content("$20.00")
        expect(page).to_not have_content("$19.60")
      end
    end

    it "The largest discount applies when there are two valid discounts." do
      discount_5 = BulkDiscount.create!(
        name: "5 for 5",
        percent_off: 5,
        min_amount: 5,
        merchant_id: @mike.id
      )

      visit "/items/#{@paper.id}"
      click_on "Add To Cart"

      visit '/cart'

      within "#cart-item-#{@pencil.id}" do
        expect(page).to have_content("$1.90")
        expect(page).to have_content("9")

        click_on "+"

        expect(page).to have_content("10")
        expect(page).to have_content("$1.80")
        expect(page).to_not have_content("$1.90")
      end
    end

    it "I get discounts from different merchants if threshold is met." do
      discount_2 = BulkDiscount.create!(
        name: "2 for 2",
        percent_off: 2,
        min_amount: 2,
        merchant_id: @meg.id
      )

      visit "/items/#{@tire.id}"
      click_on "Add To Cart"

      visit '/cart'

      within "#cart-item-#{@pencil.id}" do
        expect(page).to have_content("$2.00")
        expect(page).to have_content("9")

        click_on "+"

        expect(page).to have_content("10")
        expect(page).to have_content("$1.80")
      end

      within "#cart-item-#{@tire.id}" do
        expect(page).to have_content("$100.00")
        expect(page).to have_content("1")

        click_on "+"

        expect(page).to have_content("2")
        expect(page).to have_content("$98.00")
      end
    end
  end
end
