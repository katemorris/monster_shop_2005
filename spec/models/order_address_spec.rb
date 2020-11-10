require 'rails_helper'

RSpec.describe OrderAddress, type: :model do
  describe "relationships" do
    it { should belong_to :address }
    it { should belong_to :order }
  end
end
