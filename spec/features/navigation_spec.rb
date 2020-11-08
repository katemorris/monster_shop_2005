require 'rails_helper'

RSpec.describe 'Site Navigation' do
  describe 'As a Visitor' do
    it "I see a nav bar with links to all pages" do
      visit root_path

      within 'nav' do
        click_link 'All Items'
      end

      expect(current_path).to eq('/items')

      within 'nav' do
        click_link 'All Merchants'
      end

      expect(current_path).to eq('/merchants')

      within 'nav' do
        click_link 'Home'
      end

      expect(current_path).to eq('/')

      within 'nav' do
        click_link 'Login'
      end

      expect(current_path).to eq('/login')

      within 'nav' do
        click_link 'Register'
      end

      expect(current_path).to eq('/register')

    end

    it "I can see a cart indicator on all pages" do
      cart = Cart.new({}, {})

      visit '/merchants'

      within 'nav' do
        expect(page).to have_content("Cart: #{cart.total_items}")
      end

      visit '/items'

      within 'nav' do
        expect(page).to have_content("Cart: #{cart.total_items}")
      end

      visit '/login'

      within 'nav' do
        expect(page).to have_content("Cart: #{cart.total_items}")
      end

      visit '/register'

      within 'nav' do
        expect(page).to have_content("Cart: #{cart.total_items}")
      end

      visit '/'

      within 'nav' do
        expect(page).to have_content("Cart: #{cart.total_items}")
      end
    end

    it "I can't access paths for users of any type" do
      no_pass = "The page you were looking for doesn't exist."

      visit '/merchant'
      expect(page).to have_content(no_pass)

      visit '/admin'
      expect(page).to have_content(no_pass)

      visit '/profile'
      expect(page).to have_content(no_pass)

      visit '/admin/merchants'
      expect(page).to have_content(no_pass)

      visit '/admin/users'
      expect(page).to have_content(no_pass)

      visit '/merchant/items'
      expect(page).to have_content(no_pass)
    end
  end

  describe 'As a default user' do
    it "I see profile & logout links plus my name" do
      user = create(:user)

      visit root_path

      within 'nav' do
        click_link 'Login'
      end

      fill_in :email, with: user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      expect(current_path).to eq('/profile')

      within 'nav' do
        expect(page).to have_link('Home')
        expect(page).to have_link('All Items')
        expect(page).to have_link('Cart: 0')
        expect(page).to_not have_link('Login')
        expect(page).to_not have_link('Register')
        expect(page).to have_content("Logged in as #{user.name}")

        click_link('Profile')
        expect(current_path).to eq('/profile')

        click_link('Logout')
        expect(current_path).to eq('/')
      end
    end

    it "I can't access paths for admins or merchants" do
      user = create(:user)

      visit root_path

      within 'nav' do
        click_link 'Login'
      end

      fill_in :email, with: user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      no_pass = "The page you were looking for doesn't exist."

      visit '/merchant'
      expect(page).to have_content(no_pass)

      visit "/merchant/items/new"
      expect(page).to have_content(no_pass)

      visit '/admin'
      expect(page).to have_content(no_pass)

      visit '/admin/users'
      expect(page).to have_content(no_pass)

      visit '/admin/merchants'
      expect(page).to have_content(no_pass)
    end
  end

  describe 'As a merchant employee' do
    it "I see link to merchant dashboard among main nav links" do
      merchant = create(:merchant)
      merchant_employee = create(:user, role: 1, merchant: merchant)

      visit root_path

      within 'nav' do
        click_link 'Login'
      end

      fill_in :email, with: merchant_employee.email
      fill_in :password, with: 'password'
      click_button 'Login'

      expect(current_path).to eq('/merchant')

      within 'nav' do
        expect(page).to have_link('Home')
        expect(page).to have_link('All Items')
        expect(page).to have_link('Cart: 0')
        expect(page).to have_link('Profile')
        expect(page).to have_link('Logout')
        expect(page).to_not have_link('Login')
        expect(page).to_not have_link('Register')
        expect(page).to have_content("Logged in as #{merchant_employee.name}")
        click_link('Dashboard')
        expect(current_path).to eq('/merchant')
      end
    end

    it "I can't access paths for admins" do
      merchant = create(:merchant)
      merchant_employee = create(:user, role: 1, merchant: merchant)

      visit root_path

      within 'nav' do
        click_link 'Login'
      end

      fill_in :email, with: merchant_employee.email
      fill_in :password, with: 'password'
      click_button 'Login'

      no_pass = "The page you were looking for doesn't exist."

      visit '/admin'
      expect(page).to have_content(no_pass)

      visit '/admin/users'
      expect(page).to have_content(no_pass)

      visit '/admin/merchants'
      expect(page).to have_content(no_pass)
    end
  end

  describe 'As an admin' do
    before(:each) do
      admin = create(:user, role: 2)

      visit root_path

      within 'nav' do
        click_link 'Login'
      end

      fill_in :email, with: admin.email
      fill_in :password, with: 'password'
      click_button 'Login'
    end
    it "I see the normal links plus dashboard and all users, not cart" do
      expect(current_path).to eq('/admin')

      within 'nav' do
        expect(page).to have_link('Home')
        expect(page).to have_link('All Items')
        expect(page).to_not have_link('Cart: 0')
        expect(page).to have_link('Profile')
        expect(page).to have_link('Logout')
        expect(page).to_not have_link('Login')
        expect(page).to_not have_link('Register')

        click_link('Dashboard')
        expect(current_path).to eq('/admin')

        click_link('All Users')
        expect(current_path).to eq('/admin/users')
      end
    end

    it "I can't access paths not for admins" do
      no_pass = "The page you were looking for doesn't exist."

      visit '/cart'
      expect(page).to have_content(no_pass)
    end

    it "The link to 'All Merchants' takes me to 'admin/merchants' path" do
      click_link "All Merchants"

      expect(current_path).to eq(admin_merchants_path)
    end

    it "when I type visit '/merchants' I am redirected to 'admin/merchants'" do
      visit merchants_path
      expect(current_path).to eq(admin_merchants_path)
    end
  end
end
