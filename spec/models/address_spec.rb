require 'rails_helper'

RSpec.describe Address, type: :model do
  describe "relationships" do
    it { should belong_to :user }
    it { should have_many :order_addresses }
    it { should have_many(:orders).through(:order_addresses)}
  end
end
