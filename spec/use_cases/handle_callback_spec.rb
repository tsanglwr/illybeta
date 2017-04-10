require 'rails_helper'
require 'spec_helper'

describe Oauth::HandleCallback do

  it 'should authenticate with twitter and create a new user' do

    authhash = create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

  end

  it 'should authenticate with twitter and login an existing user' do

    authhash = create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    authhash = create_omniauth_hash('twitter', 1234, 'abcdd', 'secret2', nil, 'James9009', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq created_user.user_real_name
    expect(outcome.result.get_user.id).to eq created_user.id

  end

  it 'should authenticate with facebook and create a new user' do

    authhash = create_omniauth_hash('facebook', 9234, 'abcd', nil, nil, nil, 'Sally', "Danny")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'Sally Danny'
    expect(outcome.result.get_user.id).to_not be_nil

  end
  it 'should authenticate with facebook and login an existing user' do

    authhash = create_omniauth_hash('facebook', 9234, 'abcd', nil, nil, nil, 'Sally', "Danny")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'Sally Danny'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    authhash = create_omniauth_hash('facebook', 9234, 'abcd', nil, nil, nil, 'Sally', "Danny")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq created_user.user_real_name
    expect(outcome.result.get_user.id).to eq created_user.id

  end

  it 'should allow a twitter identity to be attached to a user created with facebook' do

    authhash = create_omniauth_hash('facebook', 9234, 'abcd', nil, nil, nil, 'Sally', "Danny")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'Sally Danny'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    authhash = create_omniauth_hash('twitter', 1234, '1abcd', 'secret', nil, 'Sally1', 'SallyPal', "Danny")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => created_user)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq created_user.user_real_name
    expect(outcome.result.get_user.id).to eq created_user.id

    # Check that both identities are associated with this user
    expect(created_user.identity.size).to eq 2
    expect(created_user.identity.first.uid).to eq "9234"
    expect(created_user.identity.first.token).to eq 'exchangedtoken'
    expect(created_user.identity.first.secret).to eq nil

    expect(created_user.identity.second.uid).to eq "1234"
    expect(created_user.identity.second.token).to eq '1abcd'
    expect(created_user.identity.second.secret).to eq 'secret'

  end

  it 'should allow a facebook identity to be attached to a user created with twitter and a network connection should be auto created' do

    authhash = create_omniauth_hash('twitter', 1234, '1abcd', 'secret', nil, 'Sally1', 'SallyPal', "Danny")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'SallyPal Danny'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    authhash = create_omniauth_hash('facebook', 9234, 'abcd', nil, nil, nil, 'Sally', "Danny")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => created_user)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq created_user.user_real_name
    expect(outcome.result.get_user.id).to eq created_user.id

    # Check that both identities are associated with this user
    expect(created_user.identity.size).to eq 2
    expect(created_user.identity.first.uid).to eq "1234"
    expect(created_user.identity.first.token).to eq '1abcd'
    expect(created_user.identity.first.secret).to eq 'secret'

    expect(created_user.identity.second.uid).to eq "9234"
    expect(created_user.identity.second.token).to eq 'exchangedtoken'
    expect(created_user.identity.second.secret).to eq nil

  end

end