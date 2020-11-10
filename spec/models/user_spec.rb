require 'rails_helper'

describe User, type: :model do
  describe 'validations' do
    it { should have_secure_password }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:street_address) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }

    it { should validate_uniqueness_of(:email) }
  end

  describe 'relationships' do
    it { should belong_to(:merchant).optional }
    it { should have_many :orders }
    it { should have_many :addresses }
  end

  describe 'instance methods' do
    describe '#enum' do
      it 'returns default for created user' do
        user = create(:user)

        expect(user.role).to eq('default')
      end

      it 'returns merchant for role 1' do
        user = create(:user, role:1)
        expect(user.role).to eq('merchant')
      end

      it 'returns admin for role 2' do
        user = create(:user, role:2)
        expect(user.role).to eq('admin')
      end
    end
  end
end
