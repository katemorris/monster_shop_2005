require 'rails_helper'

describe 'As an admin' do
  describe 'when I visit the merchant index page' do
    it 'I see all merchants in the system with thier city, state, name (as link to their dashboard), and enable/disable button' do
      admin = create(:user, role:2)

      merchant_1 = create(:merchant, name: "Bob", state: "CO", city: "Colorado Springs", enabled: true)
      merchant_2 = create(:merchant, name: "Snarfs", state: "CA", city: "Laredo", enabled: true)
      merchant_3 = create(:merchant, name: "Whiteboard", state: "ID", city: "America", enabled: false)
      merchant_4 = create(:merchant, name: "Snowy", state: "DE", city: "Monk", enabled: true)
      merchant_5 = create(:merchant, name: "Namely", state: "TX", city: "Austin", enabled: false)

      visit login_path

      fill_in :email, with: admin.email
      fill_in :password, with: 'password'
      click_button 'Login'


      click_link "All Merchants"

      within ".grid-container" do
        expect(page).to have_css(".admin-grid-item", count:5)
      end

      within "#merchant-#{merchant_1.id}" do
        expect(page).to have_link(merchant_1.name)
        expect(page).to have_content(merchant_1.city)
        expect(page).to have_content(merchant_1.state)
        expect(page).to have_button('Disable')
        expect(page).to_not have_link(merchant_2.name)
        expect(page).to_not have_content(merchant_2.city)
        expect(page).to_not have_content(merchant_2.state)
        expect(page).to_not have_button('Enable')
      end

      within "#merchant-#{merchant_3.id}" do
        expect(page).to have_link(merchant_3.name)
        expect(page).to have_content(merchant_3.city)
        expect(page).to have_content(merchant_3.state)
        expect(page).to have_button('Enable')
        expect(page).to_not have_button('Disable')
        click_link(merchant_3.name)
      end

      expect(current_path).to eq(admin_merchant_path(merchant_3))
    end
  end

  describe 'when I visit the admin user index page' do
    describe 'and click the users link in the nav' do
      it 'I see a list of all users, a link to their show page, and the type of user they are' do
        user_1 = create(:user, role:0)
        user_2 = create(:user, role:0)
        user_3 = create(:user, role:0)
        user_4 = create(:user, role:0)
        user_5 = create(:user, role:1)
        user_6 = create(:user, role:1)
        user_7 = create(:user, role:1)
        user_8 = create(:user, role:2)
        user_9 = create(:user, role:2)

        visit admin_users_path

        expect(page).to have_content("The page you were looking for doesn't exist (404)")

        visit login_path
        fill_in :email, with: user_8.email
        fill_in :password, with: 'password'
        click_button 'Login'

        click_link "Users"

        expect(current_path).to eq(admin_users_path)

        within ".users" do
          expect(page).to have_css(".user", count:9)
        end

        within "#user-#{user_1.id}" do
          expect(page).to have_content(user_1.role)
          expect(page).to have_content(user_1.created_at.strftime("%m/%d/%Y"))
          expect(page).to_not have_content(user_5.role)
          expect(page).to_not have_content(user_9.role)
          click_link(user_1.name)
        end

        expect(current_path).to eq(admin_user_path(user_1))
        expect(page).to have_content(user_1.name)
        visit admin_users_path

        within "#user-#{user_5.id}" do
          expect(page).to have_content(user_5.role)
          expect(page).to have_content(user_5.created_at.strftime("%m/%d/%Y"))
          expect(page).to_not have_content(user_3.role)
          expect(page).to_not have_content(user_8.role)
          click_link(user_5.name)
        end

        expect(current_path).to eq(admin_user_path(user_5))
        expect(page).to have_content(user_5.name)
        visit admin_users_path

        within "#user-#{user_9.id}" do
          expect(page).to have_content(user_9.role)
          expect(page).to have_content(user_9.created_at.strftime("%m/%d/%Y"))
          expect(page).to_not have_content(user_2.role)
          expect(page).to_not have_content(user_6.role)
          click_link(user_9.name)
        end

        expect(current_path).to eq(admin_user_path(user_9))
        expect(page).to have_content(user_9.name)
      end

      describe 'when I visit a users show page' do
        it 'I see the same information a user would see, except a link to edit their profile' do
          admin = create(:user, role:2)
          user = create(:user, role:0)

          visit login_path
          fill_in :email, with: admin.email
          fill_in :password, with: 'password'
          click_button 'Login'

          click_link "Users"

          within "#user-#{user.id}" do
            click_link(user.name)
          end

          expect(page).to have_content(user.name)
          expect(page).to have_content(user.email)
          expect(page).to have_content(user.created_at.strftime("%m/%d/%Y"))
          expect(page).to have_link("My Orders")

          expect(page).to_not have_link("Edit Password")
          expect(page).to_not have_link("Edit Profile Data")
        end
      end
    end


  end
end
