require 'rails_helper'

RSpec.describe 'Cart show' do
  describe 'When I have added items to my cart' do
    before(:each) do
      @mike = Merchant.create(name: "Mike's Print Shop", address: '123 Paper Rd.', city: 'Denver', state: 'CO', zip: 80203)
      @meg = Merchant.create(name: "Meg's Bike Shop", address: '123 Bike Rd.', city: 'Denver', state: 'CO', zip: 80203)

      @tire = @meg.items.create(name: "Gatorskins", description: "They'll never pop!", price: 100, image: "https://www.rei.com/media/4e1f5b05-27ef-4267-bb9a-14e35935f218?size=784x588", inventory: 12)
      @paper = @mike.items.create(name: "Lined Paper", description: "Great for writing on!", price: 20, image: "https://cdn.vertex42.com/WordTemplates/images/printable-lined-paper-wide-ruled.png", inventory: 3)
      @pencil = @mike.items.create(name: "Yellow Pencil", description: "You can write on paper with it!", price: 2, image: "https://images-na.ssl-images-amazon.com/images/I/31BlVr01izL._SX425_.jpg", inventory: 100)
      visit "/items/#{@paper.id}"
      click_on "Add To Cart"
      visit "/items/#{@tire.id}"
      click_on "Add To Cart"
      visit "/items/#{@pencil.id}"
      click_on "Add To Cart"
      @items_in_cart = [@paper,@tire,@pencil]
    end

    it 'Theres a link to checkout for users' do
      user = create(:user)
      home = create(:address, user: user, nickname: "Home")

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit "/cart"
      within("#address-#{home.id}") do
        click_on "Select"
      end
      expect(page).to have_button("Checkout")

      click_on "Checkout"

      expect(current_path).to eq("/orders/new")
    end

    it 'There is a message to register or login if a visitor' do
      visit "/cart"

      expect(page).to_not have_link("Checkout")
      expect(page).to have_link("Register")
      expect(page).to have_link("Login")
      expect(page).to have_content("Ready to checkout? Please login or register to continue.")
    end

    it 'I can complete checkout when logged in' do
      user = create(:user)
      home = create(:address, user: user, nickname: "Home")

      visit '/login'
      fill_in :email, with: user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      visit "/cart"

      within("#address-#{home.id}") do
        click_on "Select"
      end
      click_on "Checkout"
      click_on "Create Order"

      new_order = Order.last
      expect(new_order.status).to eq("pending")
      expect(new_order.user_id).to eq(user.id)
      expect(current_path).to eq("/profile/orders")
      expect(page).to have_content("Your order was successfully created!")
      expect(page).to have_content(new_order.id)
      expect(page).to have_content("Cart: 0")
    end
  end

  describe 'When I havent added items to my cart' do
    it 'There is not a link to checkout' do
      visit "/cart"

      expect(page).to_not have_link("Checkout")
    end
  end
end
