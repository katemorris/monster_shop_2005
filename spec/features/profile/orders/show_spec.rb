require 'rails_helper'

describe 'as a registered user' do
  before :each do
    @merchant = Merchant.create!(
      name: "Big Bertha's Monster Depot",
      address: "Beyond the Firey Pit",
      city: "Hell-Adjacent",
      state: "Arizona",
      zip: "66666")
    @user = create(:user)
    @home = create(:address, user: @user, nickname: "Home")
    @work = create(:address, user: @user, nickname: "Work")
    @gelatinous_cube = Item.create(
      name: "Gelatinous Cube",
      description: "A ten-foot cube of transparent gelatinous ooze.",
      price: 100,
      image: "https://www.epicpath.org/images/thumb/8/80/Gelatinous_cube.jpg/550px-Gelatinous_cube.jpg",
      inventory: 10,
      merchant_id: @merchant.id
    )
    @owlbear = Item.create(
      name: "Owlbear",
      description: "A cross between a bear and an owl. Owlbear.",
      price: 1000,
      image: "https://static.wikia.nocookie.net/forgottenrealms/images/4/43/Monster_Manual_5e_-_Owlbear_-_p249.jpg/revision/latest?cb=20141113191357",
      inventory: 2,
      merchant_id: @merchant.id
    )
    @beholder = Item.create(
      name: "Beholder",
      description: "A floating orb of flesh with a large mouth.",
      price: 10000,
      image: "https://static.wikia.nocookie.net/forgottenrealms/images/2/2c/Monster_Manual_5e_-_Beholder_-_p28.jpg/revision/latest?cb=20200313153220",
      inventory: 5,
      merchant_id: @merchant.id
    )

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
    @item_order_2 = ItemOrder.create!(
      price: @owlbear.price,
      quantity: 2,
      order_id: @order_1.id,
      item_id: @owlbear.id
    )

    @order_2 = Order.create!(
      name: 'Meg',
      address: '123 Stang Ave',
      city: 'Hershey',
      state: 'PA',
      zip: 17033,
      user_id: @user.id
    )
    @item_order_3 = ItemOrder.create!(
      price: @beholder.price,
      quantity: 1,
      order_id: @order_2.id,
      item_id: @beholder.id
    )

    visit login_path
    fill_in :email, with: @user.email
    fill_in :password, with: @user.password
    click_button "Login"
    click_link "My Orders"
  end

  describe 'visiting an orders show page to change the shipping address' do
    it "I can change the address on the order if it is pending" do
      within "#order-#{@order_1.id}" do
        click_link("#{@order_1.id}")
      end

      within('.shipping-address') do
        click_on "Change Address"
      end

      expect(current_path).to eq(profile_order_edit_path(@order_1))
    end

    it "I cannot change the address on the order if it isn't pending" do
      packaged_order = create(:order, user: @user, status: 1)
      visit profile_orders_path
      
      within "#order-#{packaged_order.id}" do
        click_link("#{packaged_order.id}")
      end

      within('.shipping-address') do
        expect(page).to_not have_content("Change Address")
      end
    end
  end

  describe 'visiting an orders show page to delete that order' do
    before :each do
      within "#order-#{@order_1.id}" do
        click_link("#{@order_1.id}")
      end

      within ".order-info" do
        click_button("Cancel Order")
      end
    end

    it 'i can click to cancel an order and each row is given status "unfulfilled"' do
      expect(@item_order_1.fulfill_status).to eq("unfulfilled")
      expect(@item_order_2.fulfill_status).to eq("unfulfilled")
    end

    it 'i can click to cancel and the order has a cancelled status' do
      visit "/profile/orders"
      within "#order-#{@order_1.id}" do
        expect(page).to have_content("cancelled")
      end
    end

    it 'i can click to cancel and the item quantities are returned to inventory' do
      expect(@gelatinous_cube.inventory).to eq(10)
      expect(@owlbear.inventory).to eq(2)
    end

    it 'i can click to cancel and i am returned to my profile page with a flash message' do
      expect(current_path).to eq("/profile")
      expect(page).to have_content("Order #{@order_1.id} has been cancelled.")
    end
  end

  describe 'when all items have been fulfilled by their merchants' do
    it 'changes the order status from "pending" to "packaged"' do
      @item_order_1.fulfill_status = "fulfilled"
      @item_order_1.save
      @item_order_2.fulfill_status = "fulfilled"
      @item_order_2.save

      within "#order-#{@order_1.id}" do
        click_link("#{@order_1.id}")
      end

      within ".order-info" do
        expect(page).to have_content("packaged")
      end
    end
  end

  describe 'when an order has been shipped' do
    it 'the user can no longer cancel it' do
      @order_1.status = "shipped"
      @order_1.save
      click_link("#{@order_1.id}")

      within ".order-info" do
        expect(page).to_not have_button("Cancel Order")
      end
    end
  end
end
