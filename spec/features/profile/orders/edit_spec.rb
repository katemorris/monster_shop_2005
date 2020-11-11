require 'rails_helper'

describe 'As a registered user' do
  describe "When I try to edit a pending order" do
    before(:each) do
      @merchant = Merchant.create!(
        name: "Big Bertha's Monster Depot",
        address: "Beyond the Firey Pit",
        city: "Hell-Adjacent",
        state: "Arizona",
        zip: "66666"
      )
      @gelatinous_cube = Item.create(
        name: "Gelatinous Cube",
        description: "A ten-foot cube of transparent gelatinous ooze.",
        price: 100,
        image: "https://www.epicpath.org/images/thumb/8/80/Gelatinous_cube.jpg/550px-Gelatinous_cube.jpg",
        inventory: 10,
        merchant_id: @merchant.id
      )

      @user = create(:user)
      @home = create(:address, user: @user, nickname: "Home")
      @work = create(:address, user: @user, nickname: "Work")

      @order_1 = Order.create!(
        name: 'Shaunda',
        address: '123 Superduper Lane',
        city: 'Cooltown',
        state: 'CO',
        zip: 80247,
        user_id: @user.id
      )

      @item_order_1 = ItemOrder.create!(
        price: @gelatinous_cube.price,
        quantity: 1,
        order_id: @order_1.id,
        item_id: @gelatinous_cube.id
      )

      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button "Login"
      visit "/profile/orders/#{@order_1.id}"
    end

    it "I can choose from my addresses" do
      within('.shipping-address') do
        click_on "Change Address"
      end

      expect(current_path).to eq(profile_order_edit_path(@order_1))

      within('.current-address') do
        expect(page).to have_content(@order_1.name)
        expect(page).to have_content(@order_1.address)
        expect(page).to have_content(@order_1.city)
        expect(page).to have_content(@order_1.state)
        expect(page).to have_content(@order_1.zip)
      end

      within('.addresses') do
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

        within("#address-#{@home.id}") do
          click_on "Select"
        end

        expect(current_path).to eq("/profile/orders/#{@order_1.id}")
        @order_1.reload
        expect(@order_1.name).to eq(@home.name)
      end
    end

    it "I can add a new address and see that one" do
      within('.shipping-address') do
        click_on "Change Address"
      end

      expect(current_path).to eq(profile_order_edit_path(@order_1))

      click_on "Add New Address"
      expect(current_path).to eq(new_profile_address_path)

      fill_in :address_nickname, with: "School"
      fill_in :address_name, with: "#{@user.name}"
      fill_in :address_street_address, with: "2334 Turing Dr."
      fill_in :address_city, with: "Denver"
      fill_in :address_state, with: "CO"
      fill_in :address_zip, with: "80202"

      click_on "Create Address"
      address = Address.last

      visit "/profile/orders/#{@order_1.id}"

      within('.shipping-address') do
        click_on "Change Address"
      end

      within("#address-#{address.id}") do
        expect(page).to have_content(address.nickname)
        expect(page).to have_content(address.name)
        expect(page).to have_content(address.street_address)
        expect(page).to have_content(address.city)
        expect(page).to have_content(address.state)
        expect(page).to have_content(address.zip)
      end
    end

    it "I cannot edit if the order is not pending" do
      packaged_order = create(:order, user: @user, status: 1)
      visit "/profile/orders/#{packaged_order.id}/edit"
      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end
end
