require 'rails_helper'

# Feature: Visit website
#   As a guest
#   I want to visit the various pages
#   So I can learn about the mission, product, and company
feature 'Visit website' do

  scenario 'should successfully visit home page' do

    visit root_path

    expect(page).to have_content 'Design and launch your microservice in minutes.'
    expect(page).to have_content 'Build better apps and services together.'

    expect(page).to have_content 'About'
    expect(page).to have_content 'Blog'
    expect(page).to have_content 'Terms'
    expect(page).to have_content 'Privacy Policy'
    expect(page).to have_content 'Contact'
    expect(page).to have_content 'Home'

  end

  scenario 'should successfully visit About page' do

    visit root_path

    click_on 'About'
    expect(page).to have_content 'About Symmetry'
    expect(page).to have_content 'Symmetry helps teams design and build services together, faster'

  end

  scenario 'should successfully have link to Blog page' do

    visit root_path

    find_link('Blog')[:href].should == 'http://blog.symmetry.io'

  end

  scenario 'should successfully visit Terms page' do

    visit root_path

    click_on 'Terms'
    expect(page).to have_content 'Last updated on: September 24th, 2015'

    expect(page).to have_content 'Account Terms'
    expect(page).to have_content 'Account Activation'
    expect(page).to have_content 'General Conditions'
    expect(page).to have_content 'Qiwibee Inc. Rights'
    expect(page).to have_content 'Limitation of Liability'
    expect(page).to have_content 'Waiver and Complete Agreement'
    expect(page).to have_content 'Intellectual Property and Customer Content'
    expect(page).to have_content 'Payment of Fees'
    expect(page).to have_content 'Cancellation and Termination'
    expect(page).to have_content 'Modifications to the Service and Prices'
    expect(page).to have_content 'Optional Tools'
    expect(page).to have_content 'DMCA Notice and Takedown Procedure'
    expect(page).to have_content 'Qiwibee Inc. reserves the right to update and change the Terms of Service'

  end

  scenario 'should successfully visit Privacy Policy page' do

    visit root_path

    click_on 'Privacy Policy'
    expect(page).to have_content 'Privacy Policy'
    expect(page).to have_content 'Introduction'

  end

  scenario 'should successfully see email Contact' do

    visit root_path

    find_link('Contact')[:href].should == 'mailto:hello@symmetry.io'

  end

end
