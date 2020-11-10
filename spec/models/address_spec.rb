require 'rails_helper'

RSpec.describe Address, type: :model do
  describe "relationships" do
    it { should belong_to :user }
    it { should have_many :order_addresses }
    it { should have_many(:orders).through(:order_addresses)}
  end

  describe "validations" do
    it { should validate_presence_of(:nickname) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:street_address) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip) }
  end

  describe "instance methods" do
    it '#has_no_orders?' do
      user = create(:user)
      home = create(:address, user: user, nickname: "Home")
      mom = create(:address, user: user, nickname: "Mom")
      order = create(:order, user: user, status: 2)
      order_address = OrderAddress.create!(order_id: order.id, address_id: mom.id)

      expect(home.has_no_orders?).to eq(true)
      expect(mom.has_no_orders?).to eq(false)
    end
  end
end
