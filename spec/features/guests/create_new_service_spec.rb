require 'rails_helper'

# Feature: Create new service
#   As a guest
#   I want to enter service api specs in swagger 2.0
#   So I can create a micro service
feature 'Create new service' do

  # Scenario: Guest launches sample service
  #   When I visit the home page
  #   Then I see "Design and launch your microservice in minutes."
  #   Then I click button "Open sample service"
  #   Then I see "Specification"
  #   Then I see "Save changes"
  #   Then I see "Deploy service"
  #   Then I click button "Deploy service"
  #   Then I see "Service deployed"
  #   Then I see "Save to account"
  scenario 'should successfully launch sample service', :js => true do

    # A disinterested guest loads a website...
    visit root_path
    expect(page).to have_content 'Design and launch your microservice in minutes.'

    # Guest becomes interested enough to decide to click for a sample
    expect(page).to have_content 'Open sample service'
    click_on 'Open sample service'

    # Immediately, a dialog appears
    # The guest finds it intriguing that there's a beautiful form populated
    expect(page).to have_content 'Swagger Petstore'

    #
    fill_in 'Name', with: 'My service'

    # guest is satisfied and intrigued, he continues to deploy this sample
   # expect(page).to have_content 'Create Service'
    click_on 'Create Service'

    # Amazing! A whole new webservice has been deployed
    # The guest can download client integrations
    # The guest can browse for more information on how to integrate more features
    # The guest can save the current backend by creating a new account
    # The guest is also satisfied to find a small reward is waiting for them to sign up on the spot.
    expect(page).to have_content 'Successfully created service'
    expect(page).to have_content 'Download Javascript client'
    expect(page).to have_content 'Download Java client'
    expect(page).to have_content 'Download Ruby client'
    expect(page).to have_content 'Download Python client'
    expect(page).to have_content 'Download PHP client'

  end

end
