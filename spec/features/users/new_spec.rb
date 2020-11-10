require 'rails_helper'

RSpec.describe "As a visitor", type: :feature do
  describe "I want to register as a user" do
    it "I can click on the register link in the nav bar and register as a user" do

      visit items_path

      within ".topnav" do
        click_link("Register")
      end

      expect(current_path).to eq("/register")

      fill_in :user_name, with: "Jun Lee"
      fill_in :user_street_address, with: "1234 America Lane"
      fill_in :user_city, with: "Denver"
      fill_in :user_state, with: "CO"
      fill_in :user_zip, with: "80017"
      fill_in :user_email, with: "jun.lee@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      click_button "Create User"

      user = User.last
      expect(user.name).to eq("Jun Lee")
      expect(user.email).to eq("jun.lee@gmail.com")

      expect(current_path).to eq("/profile")
      expect(page).to have_content("You are now registered and logged in!")
      expect(page).to have_content("Hello, #{user.name}")
    end

    it 'returns to the registration page with flash message when form is not filled out' do
      visit '/register'

      fill_in :user_street_address, with: "1234 America Lane"
      fill_in :user_city, with: "Denver"
      fill_in :user_state, with: "CO"
      fill_in :user_zip, with: "80017"
      fill_in :user_email, with: "jun.lee@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      click_button "Create User"

      expect(page).to have_content("Name can't be blank")
    end

    it 'cannot enter two different passwords' do
      visit '/register'

      fill_in :user_name, with: "Jun Lee"
      fill_in :user_street_address, with: "1234 America Lane"
      fill_in :user_city, with: "Denver"
      fill_in :user_state, with: "CO"
      fill_in :user_zip, with: "80017"
      fill_in :user_email, with: "jun.lee@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password1"

      click_button "Create User"

      expect(page).to have_content("Password confirmation doesn't match")
    end

    it 'can not register user unless email is unique' do
      user = create(:user, email: 'jun.lee@gmail.com')

      visit '/register'

      fill_in :user_name, with: "Jun Lee"
      fill_in :user_street_address, with: "1234 America Lane"
      fill_in :user_city, with: "Denver"
      fill_in :user_state, with: "CO"
      fill_in :user_zip, with: "80017"
      fill_in :user_email, with: "jun.lee@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      click_button "Create User"

      expect(find_field(:user_name).value).to eq('Jun Lee')
      expect(find_field(:user_street_address).value).to eq('1234 America Lane')
      expect(find_field(:user_city).value).to eq('Denver')
      expect(find_field(:user_state).value).to eq('CO')
      expect(find_field(:user_zip).value).to eq('80017')
      expect(find_field(:user_email).value).to eq(nil)
      expect(find_field(:user_password).value).to eq(nil)
      expect(find_field(:user_password_confirmation).value).to eq(nil)

      expect(page).to have_content('Email has already been taken')
    end
  end

  describe "Address book saving" do
    it "When I register, my address is saved as 'Home'" do
      visit '/register'

      fill_in :user_name, with: "Jun Lee"
      fill_in :user_street_address, with: "1234 America Lane"
      fill_in :user_city, with: "Denver"
      fill_in :user_state, with: "CO"
      fill_in :user_zip, with: "80017"
      fill_in :user_email, with: "jun.lee@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      click_button "Create User"
      user = User.last
      address = Address.find_by(user_id: user.id)
      expect(address.nickname).to eq("Home")
      expect(address.name).to eq("Jun Lee")
      expect(address.street_address).to eq("1234 America Lane")
      expect(address.city).to eq("Denver")
      expect(address.state).to eq("CO")
      expect(address.zip).to eq("80017")
    end
  end
end
