require 'rails_helper'

RSpec.describe "As a registered user", type: :feature do
  describe "when I visit my show page" do
    it "I see my profile data except my password and a link to edit my data" do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit "/profile"

      within ".user-profile" do
        expect(page).to have_content(user.name)
        expect(page).to have_content(user.email)
        expect(page).to have_content(user.created_at.strftime("%m/%d/%Y"))
        expect(page).to have_link("Edit Profile Data")
        expect(page).to_not have_content(user.password)
      end
    end

    it "I can edit any/all of my profile data which is updated on my profile page" do
      user = create(:user)

      visit login_path

      fill_in :email, with: user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      # visit profile_path(user)

      click_link("Edit Profile Data")

      expect(current_path).to eq(profile_edit_path)

      expect(find_field(:name).value).to eq(user.name)
      expect(find_field(:email).value).to eq(user.email)
      expect(page).to_not have_field(:password)
      expect(page).to_not have_field(:password_confirmation)

      fill_in :email, with: "fake@example.com"

      click_button "Update Profile"

      expect(current_path).to eq("/profile")

      expect(page).to have_content("Your profile is updated")

      within ".user-profile" do
        expect(page).to have_content("fake@example.com")
        expect(page).to have_content(user.created_at.strftime("%m/%d/%Y"))
      end
    end

    it "I can edit my password as long as my password fields match" do
      user = create(:user)

      visit login_path

      fill_in :email, with: user.email
      fill_in :password, with: 'password'
      click_button 'Login'

      visit "/profile"

      click_link "Edit Password"

      expect(current_path).to eq(profile_edit_path)
      expect(find_field(:password).value).to eq(nil)
      expect(find_field(:password_confirmation).value).to eq(nil)

      fill_in :password, with: "password1"
      fill_in :password_confirmation, with: "password"

      click_button "Update Password"
      expect(page).to have_content("Password confirmation doesn't match Password")

      fill_in :password, with: "password1"
      fill_in :password_confirmation, with: "password1"

      click_button "Update Password"

      expect(current_path).to eq("/profile")
      expect(page).to have_content("Your password is updated")
    end

    it "I can update my email if it is a unique email" do
      user1 = create(:user, email: "mike.dao@example.com")
      user2 = create(:user)

      visit login_path

      fill_in :email, with: user2.email
      fill_in :password, with: 'password'
      click_button 'Login'

      visit "/profile"

      click_link "Edit Profile Data"

      fill_in :email, with: user1.email

      click_button "Update Profile"

      expect(current_path).to eq(profile_edit_path)
      expect(page).to have_content("Email has already been taken")
      expect(find_field(:name).value).to eq(user2.name)
      expect(find_field(:email).value).to eq(user2.email)
      expect(page).to_not have_field(:password)
      expect(page).to_not have_field(:password_confirmation)
    end

  end
end
