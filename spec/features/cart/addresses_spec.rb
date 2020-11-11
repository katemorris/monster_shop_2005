require 'rails_helper'

RSpec.describe 'Cart show' do
  describe "When I am ready to check out, I can choose an address" do
    before(:each) do
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

      @user = create(:user)
      @home = create(:address, user: @user, nickname: "Home", zip: "19876")
      @work = create(:address, user: @user, nickname: "Work", zip: "19876")

      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Login"

      visit item_path(@tire)
      click_on "Add To Cart"
      visit cart_path
    end

    it "I can see multiple addresses" do
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
    end

    it "I can choose an address and that is sent to the order." do
      within("#address-#{@home.id}") do
        click_on "Select"
      end

      click_on "Checkout"
      expect(current_path).to eq(orders_new_path)
      expect(page).to have_content(@home.name)
      expect(page).to have_content(@home.street_address)
      expect(page).to have_content(@home.city)
      expect(page).to have_content(@home.state)
      expect(page).to have_content(@home.zip)

      click_on "Create Order"
      expect(current_path).to eq("/profile/orders")
      new_order = Order.last
      click_on "#{new_order.id}"

      expect(page).to have_content(@home.name)
      expect(page).to have_content(@home.street_address)
      expect(page).to have_content(@home.city)
      expect(page).to have_content(@home.state)
      expect(page).to have_content(@home.zip)
    end

    it "If I have no addresses, I am asked to add an address." do
      click_on "Logout"
      no_address_user = create(:user)

      visit login_path
      fill_in :email, with: no_address_user.email
      fill_in :password, with: no_address_user.password
      click_button "Login"

      visit item_path(@tire)
      click_on "Add To Cart"
      visit cart_path

      expect(page).to have_content("Please add an address to your account.")
      expect(page).to have_link("Add a New Address")
    end

  end
end
