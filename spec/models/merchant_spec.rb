require 'rails_helper'

describe Merchant, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe "relationships" do
    it {should have_many :items}
    it {should have_many :users}
    it {should have_many :bulk_discounts}
    it {should have_many(:orders).through(:items)}
  end

  describe 'instance methods' do
    describe '#item_count' do
      before(:each) do
        @merchant = create(:merchant)
        create(:item, merchant: @merchant)
        create(:item, merchant: @merchant)
        create(:item, merchant: @merchant)
      end
      it 'returns the total number of a merchants unqiue items' do
        expect(@merchant.item_count).to eq(3)
      end

      it 'only counts a single merchants items' do
        merchant_2 = create(:merchant, :with_items, item_count: 6)
        expect(@merchant.item_count).to eq(3)
      end
    end

    describe '#average_item_price' do
      it 'returns the average item price a merchants items' do
        merchant = create(:merchant)
        create(:item, price: 4, merchant: merchant)
        create(:item, price: 2, merchant: merchant)
        create(:item, price: 6, merchant: merchant)

        expect(merchant.average_item_price).to eq(4)
      end

      it "returns the average price for only one merchant's items" do
        merchant = create(:merchant)
        merchant_2 = create(:merchant)
        create(:item, price: 4, merchant: merchant)
        create(:item, price: 2, merchant: merchant)
        create(:item, price: 6, merchant: merchant)
        create(:item, price: 6, merchant: merchant_2)
        create(:item, price: 6, merchant: merchant_2)

        expect(merchant_2.average_item_price).to eq(6)
      end

      it "calculates float averages" do
        merchant = create(:merchant)
        create(:item, price: 6, merchant: merchant)
        create(:item, price: 7, merchant: merchant)

        expect(merchant.average_item_price).to eq(6.5)
      end
    end

    describe '#distinct_cities' do
      it 'returns array of unique city names from items ordered' do
        user = create(:user, email: 'testing@example.com')
        merchant = create(:merchant, :with_items)
        order1 = create(:order, city: 'Hershey', user_id: user.id)
        order2 = create(:order, city: 'Denver', user_id: user.id)
        order3 = create(:order, city: 'Denver', user_id: user.id)
        create(:item_order, item: merchant.items[0], order: order1)
        create(:item_order, item: merchant.items[0], order: order2)
        create(:item_order, item: merchant.items[0], order: order3)

        expected = ['Denver', 'Hershey']
        expect(merchant.distinct_cities.sort).to eq(expected.sort)
      end
    end

    describe '#enabled?' do
      context 'when merchant is enabled' do
        it 'returns true' do
          merchant = build(:merchant, enabled: true)
          expect(merchant.enabled?).to eq(true)
        end
      end

      context 'when merchant is disabled' do
        it 'returns false' do
          merchant = build(:merchant, enabled: false)
          expect(merchant.enabled?).to eq(false)
        end
      end
    end

    describe '#status' do
      context 'when merchant is enabled' do
        it "returns 'Enabled'" do
          merchant = build(:merchant, enabled: true)
          expect(merchant.status).to eq('Enabled')
        end
      end

      context 'when merchant is disabled' do
        it "returns 'Disabled'" do
          merchant = build(:merchant, enabled: false)
          expect(merchant.status).to eq('Disabled')
        end
      end
    end

    describe '#disable_items' do
      it 'disables all merchant items' do
        merchant = create(:merchant)
        item_1 = create(:item, merchant: merchant, active?: true)
        item_2 = create(:item, merchant: merchant, active?: true)
        item_3 = create(:item, merchant: merchant, active?: true)

        merchant.disable_items
        merchant.reload
        expect(merchant.items[0].active?).to eq(false)
        expect(merchant.items[1].active?).to eq(false)
        expect(merchant.items[2].active?).to eq(false)
      end
    end

    describe '#enable_items' do
      it 'enables all merchant items' do
        merchant = create(:merchant)
        create_list(:item, 3, active?: false, merchant: merchant)

        merchant.enable_items
        merchant.reload
        expect(merchant.items[0].active?).to eq(true)
        expect(merchant.items[1].active?).to eq(true)
        expect(merchant.items[2].active?).to eq(true)
      end
    end

    describe '#pending_orders' do
      it 'returns pending orders for a merchant' do
        merchant = create(:merchant)

        item_1 = create(:item, merchant: merchant)
        item_2 = create(:item, merchant: merchant)
        item_3 = create(:item, merchant: merchant)

        order_1 = create(:order, status: 'pending')
        order_2 = create(:order, status: 'pending')
        order_3 = create(:order, status: 'pending')

        io_1 = create(:item_order, item: item_1, order: order_1)
        io_2 = create(:item_order, item: item_2, order: order_2)
        io_3 = create(:item_order, item: item_3, order: order_3)

        expected = [order_1, order_2, order_3]

        expect(merchant.pending_orders.sort).to eq(expected.sort)
      end

      it 'does not return orders that are not pending for a merchant' do
        merchant = create(:merchant)

        item_1 = create(:item, merchant: merchant)
        item_2 = create(:item, merchant: merchant)
        item_3 = create(:item, merchant: merchant)
        order_1 = create(:order, status: 'packaged')
        order_2 = create(:order, status: 'pending')
        order_3 = create(:order, status: 'pending')

        io_1 = create(:item_order, item: item_1, order: order_1)
        io_2 = create(:item_order, item: item_2, order: order_2)
        io_3 = create(:item_order, item: item_3, order: order_3)

        expected = [order_2, order_3]

        expect(merchant.pending_orders).to eq(expected)
      end

      it 'does not return orders for other merchants' do
        merchant = create(:merchant)
        merchant_2 = create(:merchant)

        item_1 = create(:item, merchant: merchant)
        item_2 = create(:item, merchant: merchant)
        item_3 = create(:item, merchant: merchant_2)

        io_1 = create(:item_order, item: item_1)
        io_2 = create(:item_order, item: item_2)
        io_3 = create(:item_order, item: item_3)

        order_1 = io_1.order
        order_2 = io_2.order
        order_3 = io_3.order

        expected = [order_1, order_2]

        expect(merchant.pending_orders).to eq(expected)
      end
    end

    describe "#order_item_quantity" do
      it "returns number of items in a merchant order for only identified merchant" do

        admin = create(:user, role:2)
        merchant = create(:merchant, name: "Once Upon a Time")
        merchant_2 = create(:merchant)

        item_1 = create(:item, merchant: merchant)
        item_2 = create(:item, merchant: merchant)
        item_3 = create(:item, merchant: merchant_2)
        item_4 = create(:item, merchant: merchant_2)
        item_5 = create(:item, merchant: merchant_2)

        order_1 = create(:order)
        order_2 = create(:order)

        item_order_1 = create(:item_order, order: order_1, item: merchant.items[0])
        item_order_2 = create(:item_order, order: order_1, item: merchant.items[1])
        item_order_3 = create(:item_order, order: order_1, item: merchant_2.items[0])
        item_order_4 = create(:item_order, order: order_1, item: merchant_2.items[1])
        item_order_5 = create(:item_order, order: order_1, item: merchant_2.items[2])

        item_order_7 = create(:item_order, order: order_2, item: merchant.items[1])
        item_order_8 = create(:item_order, order: order_2, item: merchant_2.items[1])
        item_order_9 = create(:item_order, order: order_2, item: merchant_2.items[2])

        expect(merchant.order_item_quantity(order_1)).to eq(2)
        expect(merchant.order_item_quantity(order_2)).to eq(1)

        expect(merchant_2.order_item_quantity(order_1)).to eq(3)
        expect(merchant_2.order_item_quantity(order_2)).to eq(2)
      end
    end

    describe "#order_total" do
      it "returns the total price of a merchant's order for only selected merchant" do
        admin = create(:user, role:2)
        merchant = create(:merchant, name: "Once Upon a Time")
        merchant_2 = create(:merchant)

        item_1 = create(:item, merchant: merchant)
        item_2 = create(:item, merchant: merchant)
        item_3 = create(:item, merchant: merchant_2)
        item_4 = create(:item, merchant: merchant_2)
        item_5 = create(:item, merchant: merchant_2)

        order_1 = create(:order)
        order_2 = create(:order)

        item_order_1 = create(:item_order, order: order_1, item: merchant.items[0])
        item_order_2 = create(:item_order, order: order_1, item: merchant.items[1])
        item_order_3 = create(:item_order, order: order_1, item: merchant_2.items[0])
        item_order_4 = create(:item_order, order: order_1, item: merchant_2.items[1])
        item_order_5 = create(:item_order, order: order_1, item: merchant_2.items[2])

        item_order_7 = create(:item_order, order: order_2, item: merchant.items[1])
        item_order_8 = create(:item_order, order: order_2, item: merchant_2.items[1])
        item_order_9 = create(:item_order, order: order_2, item: merchant_2.items[2])

        sum_1 = item_order_1.price + item_order_2.price
        sum_2 = item_order_3.price + item_order_4.price + item_order_5.price
        sum_3 = sum_1 + sum_2

        expect(merchant.order_total(order_1)).to eq(sum_1)
        expect(merchant_2.order_total(order_1)).to eq(sum_2)
      end
    end

  end
end
