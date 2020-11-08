require 'rails_helper'

RSpec.describe Cart do
  describe 'Instance Methods' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', inventory: 2 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', inventory: 13 )
      @cart = Cart.new({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        }, {
          @ogre.id.to_s => @ogre.price,
          @giant.id.to_s => @giant.price
          })

      @discount_10 = BulkDiscount.create!(name: "10 for 10", percent_off: 10, min_amount: 10, merchant_id: @brian.id)
      @cart1 = Cart.new({
        @hippo.id.to_s => 10
        }, {@hippo.id.to_s => @hippo.price})
      @cart2 = Cart.new({
        @hippo.id.to_s => 9
        }, {@hippo.id.to_s => @hippo.price})
    end

    it '.contents' do
      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })
    end

    it '.item_prices' do
      expect(@cart.item_prices).to eq({
        @ogre.id.to_s => @ogre.price,
        @giant.id.to_s => @giant.price
        })
    end

    describe "#add_item()" do
      it '.it will add an item that doesnt exist' do
        @cart.add_item(@hippo)

        expect(@cart.contents).to eq({
          @ogre.id.to_s => 1,
          @giant.id.to_s => 2,
          @hippo.id.to_s => 1
          })
      end

      it '.it will add an item that does exist' do
        @cart.add_item(@ogre)

        expect(@cart.contents).to eq({
          @ogre.id.to_s => 2,
          @giant.id.to_s => 2,
          })
      end
    end

    it ".get_price()" do
      @cart.get_price(@giant)

      expect(@cart.item_prices[@giant.id.to_s]).to eq(@giant.price)
    end

    it ".check_for_removal()" do
      expect(@cart.check_for_removal(@ogre)).to eq(nil)
      expect(@cart.contents).to eq({
        @ogre.id.to_s => 1,
        @giant.id.to_s => 2
        })

      @cart.contents[@ogre.id.to_s] -= 1
      expect(@cart.check_for_removal(@ogre)).to eq(0)
      expect(@cart.contents).to eq({
        @giant.id.to_s => 2
        })
    end

    describe ".reset_price_check()" do
      before(:each) do
        discount_5 = BulkDiscount.create!(name: "2 for 5", percent_off: 5, min_amount: 2, merchant_id: @brian.id)
      end

      it "when discount is present" do
        @cart.add_item(@hippo)
        expect(@cart.item_prices[@hippo.id.to_s]).to eq(@hippo.price)

        @cart.add_item(@hippo)
        @cart.apply_discounts
        expect(@cart.item_prices[@hippo.id.to_s]).to eq(@hippo.price-(@hippo.price * 0.05))
        expect(@cart.reset_price_check(@hippo)).to eq(nil)
      end
      it "when discount is removed" do
        @cart.add_item(@hippo)
        @cart.add_item(@hippo)
        @cart.apply_discounts
        @cart.contents[@hippo.id.to_s] -= 1
        expect(@cart.reset_price_check(@hippo)).to eq(@hippo.price)
      end
    end

    describe "#remove_one()" do
      it ".it will remove a single quantity" do
        @cart.remove_one(@giant)

        expect(@cart.contents).to eq({
          @ogre.id.to_s => 1,
          @giant.id.to_s => 1
          })
      end

      it ".it will remove item" do
        @cart.remove_one(@giant)
        @cart.remove_one(@giant)

        expect(@cart.contents).to eq({
          @ogre.id.to_s => 1
          })
      end
    end

    it '.total_items' do
      expect(@cart.total_items).to eq(3)
    end

    it '.items' do
      expect(@cart.items).to eq({@ogre => 1, @giant => 2})
    end

    it '.total' do
      expect(@cart.total).to eq(120)

      # When discounts present
      @cart1.apply_discounts
      expect(@cart1.total).to eq(450)
    end

    it '.subtotal()' do
      expect(@cart.subtotal(@ogre)).to eq(20)
      expect(@cart.subtotal(@giant)).to eq(100)

      # When discounts present
      @cart1.apply_discounts
      expect(@cart1.subtotal(@hippo)).to eq(450)
    end

    it '.inventory_check(item)' do
      expect(@cart.inventory_check(@giant)).to eq(false)
      expect(@cart.inventory_check(@ogre)).to eq(true)
    end

    it ".find_discount(item_id)" do
      expect(@cart1.find_discount(@hippo.id.to_s)).to eq([@discount_10])

      discount_5 = BulkDiscount.create!(name: "5 for 5", percent_off: 5, min_amount: 5, merchant_id: @brian.id)
      discounts = [@discount_10, discount_5]

      expect(@cart1.find_discount(@hippo.id.to_s).sort).to eq(discounts.sort)
    end

    it ".find_discounts" do
      expect(@cart.find_discounts).to eq([])

      expect(@cart1.find_discounts).to eq([@discount_10])


      expect(@cart2.find_discounts).to eq([])
    end

    it ".has_discounts?" do
      expect(@cart1.has_discounts?).to eq(true)
      expect(@cart2.has_discounts?).to eq(false)
    end

    it ".get_max_discount(set)" do
      discount_5 = BulkDiscount.create!(name: "5 for 5", percent_off: 5, min_amount: 5, merchant_id: @brian.id)
      discounts = [@discount_10, discount_5]

      expect(@cart.get_max_discount(discounts)).to eq(@discount_10)
      expect(@cart.get_max_discount([@discount_10])).to eq(@discount_10)
      expect(@cart.get_max_discount([])).to eq(nil)
    end

    it ".apply_discounts" do
      expected = { @hippo.id.to_s => 45.0 }
      expect(@cart1.apply_discounts).to eq(expected)

      normal = { @hippo.id.to_s => 50.0 }
      expect(@cart2.apply_discounts).to eq(normal)
    end
  end
end
