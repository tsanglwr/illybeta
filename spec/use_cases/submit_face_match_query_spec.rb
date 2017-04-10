require 'rails_helper'
require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe Matching::SubmitFaceMatchQuery do

  it 'should successfully submit face match query for user' do

    outcome = Oauth::HandleCallback.run(:auth => create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango"), :auth_params => {}, :user => nil)
    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    image_file = File.new(Rails.root + 'spec/use_cases/test_assets/charlie-sheen.jpg')
    outcome = Matching::CreateFaceMatchResult.run(user_id: created_user.id, account_uuid: created_user.account.first.account_uuid, image: image_file)

    expect(outcome.valid?).to eq true
  end

  it 'should successfully submit face match query for user' do

    outcome = Oauth::HandleCallback.run(:auth => create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango"), :auth_params => {}, :user => nil)
    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    image_file = File.new(Rails.root + 'spec/use_cases/test_assets/charlie-sheen.jpg')
    outcome = Matching::CreateFaceMatchResult.run(user_id: created_user.id, account_uuid: created_user.account.first.account_uuid, image: image_file)

    expect(outcome.valid?).to eq true
  end

end
