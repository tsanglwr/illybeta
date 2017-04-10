require 'rails_helper'
require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe Accounts::CreateFirstAccountForUser do

  it 'should create an account after signing up with twitter' do

    authhash = create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be true
    expect(update_outcome.result.first.email).to eq 'someone@somewhere97462.com'
    expect(created_user.account.first.site_name).to eq 'mysite'

  end

  it 'should create an account after signing up with facebook' do

    authhash = create_omniauth_hash('facebook', 1234, 'abcd', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be true
    expect(update_outcome.result.first.email).to eq 'someone@somewhere97462.com'
    expect(created_user.account.first.site_name).to eq 'mysite'


   # expect(Streams::GetStreamSources.run!(:account_id => update_outcome.result.second.id, :stream_id => update_outcome.result.second.stream.first.id).size).to eq 1

  end

  it 'should create an account after signing up with just an email' do

    create_user

    # Create an account
    update_outcome = Accounts::CreateFirstAccountForUser.run(:user_id => @user.id,
                                                            :site_name => 'mysite')
    expect(update_outcome.result.id).to_not be_nil
  end

  it 'should not create an account with the same site name as another account' do

    create_user

    # Create an account
    update_outcome = Accounts::CreateFirstAccountForUser.run(:user_id => @user.id,
                                                             :site_name => 'mysite')
    expect(update_outcome.result.id).to_not be_nil

    create_user

    # Create an account
    update_outcome = Accounts::CreateFirstAccountForUser.run(:user_id => @user.id,
                                                             :site_name => 'mysite')
    expect(update_outcome.success?).to eq false
    expect(update_outcome.errors.symbolic[:account]).to eq :business_name_in_use
  end

  it 'should create a default network connection after attaching with twitter' do

    authhash = create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be true
    expect(update_outcome.result.first.email).to eq 'someone@somewhere97462.com'
    expect(created_user.account.first.site_name).to eq 'mysite'

    account = update_outcome.result.second
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)

    expect(network_outcome.success?).to be true

    networks = network_outcome.result
    expect(networks.first.network).to eq 'twitter'
    expect(networks.first.uid).to eq '1234'
    expect(networks.first.twitter_type).to eq 'profile'

    # Ensure that the network credentials, streams, and streams sources are added

  end
  it 'should create a default network connection after attaching with facebook' do

    authhash = create_omniauth_hash('facebook', 12345, 'abcd', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be true
    expect(update_outcome.result.first.email).to eq 'someone@somewhere97462.com'
    expect(created_user.account.first.site_name).to eq 'mysite'


    account = update_outcome.result.second
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)

    expect(network_outcome.success?).to be true

    networks = network_outcome.result
    expect(networks.first.network).to eq 'facebook'
    expect(networks.first.uid).to eq '12345'
    expect(networks.first.facebook_type).to eq 'profile'

  end
  it 'should attach twitter to an existing account created with just an email' do

    create_user

    # Create an account
    update_outcome = Accounts::CreateFirstAccountForUser.run(:user_id => @user.id,
                                                             :site_name => 'mysite')

    account = update_outcome.result
    expect(account.id).to_not be_nil

    # Attach twitter
    authhash = create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq nil
    expect(outcome.result.get_user.id).to_not be_nil
    created_user = outcome.result.get_user

    # Check that the identity exists
    expect(created_user.identity.first.uid).to eq "1234"

    # Ensure that the network connection does not exist (Since it was just a login, and not an explicit attachment above)
    network_outcome = Network::GetNetworkConnections.run(:account_id => created_user.account.first.id)

    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 0

    # Now attach twitter account with an explicit state set to attach it also as a network connection (verify that token and secret are updated too)
    authhash = create_omniauth_hash('twitter', 1234, 'abcd2', 'secret2', nil, 'James9009', 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'twitterprofile', :aux => 'network_attach'}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    expect(outcome.result.get_user.user_real_name).to eq nil
    expect(outcome.result.get_user.id).to_not be_nil
    created_user = outcome.result.get_user

    # Check that the identity was updated
    expect(created_user.identity.first.uid).to eq "1234"
    expect(created_user.identity.first.token).to eq 'abcd2'
    expect(created_user.identity.first.secret).to eq 'secret2'

    # Verify that there are 1 network connections with this user now

    network_outcome = Network::GetNetworkConnections.run(:account_id => created_user.account.first.id)

    expect(network_outcome.success?).to eq true

    expect(network_outcome.result.size).to eq 1
    expect(network_outcome.result.first.uid).to eq "1234"
    expect(network_outcome.result.first.token).to eq "abcd2"
    expect(network_outcome.result.first.secret).to eq "secret2"

  end

  it 'should attach facebook to an existing account created with just an email' do
    create_user

    # Create an account
    update_outcome = Accounts::CreateFirstAccountForUser.run(:user_id => @user.id,
                                                             :site_name => 'mysite')

    account = update_outcome.result
    expect(account.id).to_not be_nil

    # Attach facebook
    authhash = create_omniauth_hash('facebook', 9234, 'abcd', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end


    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq nil
    expect(outcome.result.get_user.id).to_not be_nil
    created_user = outcome.result.get_user

    # Check that the identity exists
    expect(created_user.identity.first.uid).to eq "9234"

    # Ensure that the network connection does not exist (Since it was just a login, and not an explicit attachment above)
    network_outcome = Network::GetNetworkConnections.run(:account_id => created_user.account.first.id)

    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 0

    # Now attach twitter account with an explicit state set to attach it also as a network connection (verify that token and secret are updated too)
    authhash = create_omniauth_hash('facebook', 9234, 'abcd2', nil, nil, nil, 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'fbprofile', :aux => 'network_attach'}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    expect(outcome.result.get_user.user_real_name).to eq nil
    expect(outcome.result.get_user.id).to_not be_nil
    created_user = outcome.result.get_user

    # Check that the identity was updated
    expect(created_user.identity.first.uid).to eq "9234"
    expect(created_user.identity.first.token).to eq 'exchangedtoken'
    expect(created_user.identity.first.secret).to eq nil

    # Verify that there are 1 network connections with this user now

    network_outcome = Network::GetNetworkConnections.run(:account_id => created_user.account.first.id)

    expect(network_outcome.success?).to eq true

    expect(network_outcome.result.size).to eq 1
    expect(network_outcome.result.first.uid).to eq "9234"
    expect(network_outcome.result.first.token).to eq "exchangedtoken"
    expect(network_outcome.result.first.secret).to eq nil

  end

  it 'should attach twitter to an existing account created with facebook' do


    authhash = create_omniauth_hash('facebook', 1234, 'abcd', nil, nil, '', 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end


    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    account = update_outcome.result.second
    expect(update_outcome.success?).to be true
    expect(update_outcome.result.first.email).to eq 'someone@somewhere97462.com'
    expect(created_user.account.first.site_name).to eq 'mysite'


    # Attach facebook
    authhash = create_omniauth_hash('twitter', 9234, 'abcde', 'secret5', nil, 'James932', 'James', "Jango")


    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => created_user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq "James Jango"
    expect(outcome.result.get_user.id).to_not be_nil
    created_user = outcome.result.get_user

    # Check that the identity exists
    expect(created_user.identity.first.uid).to eq "1234"
    expect(created_user.identity.second.uid).to eq "9234"

    # Ensure that the network connection does not exist (Since it was just a login, and not an explicit attachment above)
    network_outcome = Network::GetNetworkConnections.run(:account_id => created_user.account.first.id)

    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1
    expect(network_outcome.result.first.uid).to eq "1234"

    # Now attach facebook account with an explicit state set to attach it also as a network connection (verify that token and secret are updated too)
    authhash = create_omniauth_hash('twitter', 9234, 'abcde', 'secret10', nil, 'James932', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'twitterprofile', :aux => 'network_attach'}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    expect(outcome.result.get_user.user_real_name).to eq "James Jango"
    expect(outcome.result.get_user.id).to_not be_nil
    created_user = outcome.result.get_user

    # Check that the identity was updated

    expect(created_user.identity.first.uid).to eq "1234"
    expect(created_user.identity.first.token).to eq 'exchangedtoken'
    expect(created_user.identity.first.secret).to eq nil

    expect(created_user.identity.second.uid).to eq "9234"
    expect(created_user.identity.second.token).to eq 'abcde'
    expect(created_user.identity.second.secret).to eq 'secret10'

    # Verify that there are 2 network connections with this user now

    network_outcome = Network::GetNetworkConnections.run(:account_id => created_user.account.first.id)

    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 2


    expect(network_outcome.result.first.uid).to eq "1234"
    expect(network_outcome.result.first.token).to eq "exchangedtoken"
    expect(network_outcome.result.first.secret).to eq nil

    expect(network_outcome.result.second.uid).to eq "9234"
    expect(network_outcome.result.second.token).to eq "abcde"
    expect(network_outcome.result.second.secret).to eq 'secret10'

  end

  it 'should attach facebook to an existing account created with twitter' do

    authhash = create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    account = update_outcome.result.second
    expect(update_outcome.success?).to be true
    expect(update_outcome.result.first.email).to eq 'someone@somewhere97462.com'
    expect(created_user.account.first.site_name).to eq 'mysite'








    # Attach facebook
    authhash = create_omniauth_hash('facebook', 9234, 'abcd', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end


    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => created_user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq "James Jango"
    expect(outcome.result.get_user.id).to_not be_nil
    created_user = outcome.result.get_user

    # Check that the identity exists
    expect(created_user.identity.first.uid).to eq "1234"
    expect(created_user.identity.second.uid).to eq "9234"

    # Ensure that the network connection does not exist (Since it was just a login, and not an explicit attachment above)
    network_outcome = Network::GetNetworkConnections.run(:account_id => created_user.account.first.id)

    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1
    expect(network_outcome.result.first.uid).to eq "1234"

    # Now attach facebook account with an explicit state set to attach it also as a network connection (verify that token and secret are updated too)
    authhash = create_omniauth_hash('facebook', 9234, 'abcd2', nil, nil, nil, 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'fbprofile', :aux => 'network_attach'}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    expect(outcome.result.get_user.user_real_name).to eq "James Jango"
    expect(outcome.result.get_user.id).to_not be_nil
    created_user = outcome.result.get_user

    # Check that the identity was updated

    expect(created_user.identity.first.uid).to eq "1234"
    expect(created_user.identity.first.token).to eq 'abcd'
    expect(created_user.identity.first.secret).to eq 'secret'

    expect(created_user.identity.second.uid).to eq "9234"
    expect(created_user.identity.second.token).to eq 'exchangedtoken'
    expect(created_user.identity.second.secret).to eq nil

    # Verify that there are 2 network connections with this user now

    network_outcome = Network::GetNetworkConnections.run(:account_id => created_user.account.first.id)

    expect(network_outcome.success?).to eq true

    expect(network_outcome.result.size).to eq 2


    expect(network_outcome.result.first.uid).to eq "1234"
    expect(network_outcome.result.first.token).to eq "abcd"
    expect(network_outcome.result.first.secret).to eq 'secret'

    expect(network_outcome.result.second.uid).to eq "9234"
    expect(network_outcome.result.second.token).to eq "exchangedtoken"
    expect(network_outcome.result.second.secret).to eq nil


  end

  it 'should not allow a user to be updated with an invalid email' do

    authhash = create_omniauth_hash('facebook', 1234, 'abcd', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => '',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be false
    expect(update_outcome.errors.symbolic[:user]).to be_nil

    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'notanemail',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be false
    expect(update_outcome.errors.symbolic[:user]).to eq :email

  end

  it 'should not allow a user to be updated with an invalid password' do

    authhash = create_omniauth_hash('facebook', 1234, 'abcd', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'email@asjhfjsdfsjf.com',
                                                       :password => '',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be false
    expect(update_outcome.errors.symbolic[:password]).to eq :empty

    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'j124kjwefjk@asdfsd.com',
                                                       :password => 'short',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be false
    expect(update_outcome.errors.symbolic[:user]).to eq :password

  end

  it 'should not allow an account to be created with an invalid site name' do


    authhash = create_omniauth_hash('facebook', 1234, 'abcd', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'email@asjhfjsdfsjf.com',
                                                       :password => 'password',
                                                       :site_name => '')

    expect(update_outcome.success?).to be false
    expect(update_outcome.errors.symbolic[:site_name]).to eq :empty

    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'j124kjwefjk@asdfsd.com',
                                                       :password => 'password',
                                                       :site_name => 'a')

    expect(update_outcome.success?).to be false
    expect(update_outcome.errors.symbolic[:site_name]).to eq :min_length

  end

  it 'should allow only 1 user to login and/or attach the same identity' do

    # Create the first user

    authhash = create_omniauth_hash('facebook', 1234, 'abcd', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    user1 = outcome.result.get_user
    # Result: New user and identity created
    expect(user1.identity.size).to eq 1

    # Attempt to create another user with the same identity

    authhash = create_omniauth_hash('facebook', 1234, 'abcdef', nil, nil, nil, 'Jon', "Bob")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    user1_found = outcome.result.get_user
    # Result:  Same user is returned
    expect(user1_found.id).to eq user1.id

    # Create another user, then attach the first identity

    authhash = create_omniauth_hash('facebook', 123456, 'abcdef', nil, nil, nil, 'Alice', "Wonder")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'Alice Wonder'
    expect(outcome.result.get_user.id).to_not be_nil
    user2 = outcome.result.get_user

    # Attach the previous identity

    authhash = create_omniauth_hash('facebook', 1234, 'abcd', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => user2)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq 'Alice Wonder'
    expect(outcome.result.get_user.id).to_not be_nil

    user2_attached = outcome.result.get_user

    # Result: The most recent user 'stole' the identity from the other
    expect(user2_attached.identity.first.uid).to eq "1234"
    expect(user2_attached.identity.second.uid).to eq "123456"

    expect(user1.identity.size).to eq 0


  end

  it 'should update facebook network connection credentials after a successful login with the associated social identity' do

    # Create the first user
    authhash = create_omniauth_hash('facebook', 1000, '0000', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    user1 = outcome.result.get_user
    expect(user1.identity.size).to eq 1

    # Update the
    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => user1.id,
                                                       :email => 'fooboo@asdfsdf332.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be true

    network_outcome = Network::GetNetworkConnections.run(:account_id => user1.account.first.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "1000"
    expect(network_outcome.result.first.token).to eq "exchangedtoken"
    expect(network_outcome.result.first.secret).to eq nil


    # Update the connection by fresh login (user => nil)

    authhash = create_omniauth_hash('facebook', 1000, '0000', nil, nil, nil, 'James', "Jango")

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken2'
    end

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    network_outcome = Network::GetNetworkConnections.run(:account_id => user1.account.first.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "1000"
    expect(network_outcome.result.first.token).to eq "exchangedtoken2"
    expect(network_outcome.result.first.secret).to eq nil

    # Update the connection by connected login (user => model)

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken3'
    end

    authhash = create_omniauth_hash('facebook', 1000, '1000', nil, nil, nil, 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => user1)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    network_outcome = Network::GetNetworkConnections.run(:account_id => user1.account.first.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "1000"
    expect(network_outcome.result.first.token).to eq "exchangedtoken3"
    expect(network_outcome.result.first.secret).to eq nil

  end
  it 'should update twitter network connection credentials after a successful login with the associated social identity' do

    authhash = create_omniauth_hash('twitter', 2000, '2000', 'secret1', nil, 'JamesJango', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    user1 = outcome.result.get_user
    expect(user1.identity.size).to eq 1

    # Update the
    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => user1.id,
                                                       :email => 'fooboo@asdfsdf332.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be true

    network_outcome = Network::GetNetworkConnections.run(:account_id => user1.account.first.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "2000"
    expect(network_outcome.result.first.token).to eq "2000"
    expect(network_outcome.result.first.secret).to eq 'secret1'

    # Update the connection by fresh login (user => nil)
    authhash = create_omniauth_hash('twitter', 2000, '2001', 'secret2', nil, 'JamesJango', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    network_outcome = Network::GetNetworkConnections.run(:account_id => user1.account.first.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "2000"
    expect(network_outcome.result.first.token).to eq "2001"
    expect(network_outcome.result.first.secret).to eq 'secret2'

    # Update the connection by connected login (user => model)

    authhash = create_omniauth_hash('twitter', 2000, '2002', 'secret3', nil, 'JamesJango', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => user1)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    network_outcome = Network::GetNetworkConnections.run(:account_id => user1.account.first.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "2000"
    expect(network_outcome.result.first.token).to eq "2002"
    expect(network_outcome.result.first.secret).to eq 'secret3'

  end

  it 'should correctly unassign network connections from another user when the identity gets transferred away' do


    authhash = create_omniauth_hash('twitter', 2000, '2000', 'secret1', nil, 'JamesJango', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    user1 = outcome.result.get_user
    expect(user1.identity.size).to eq 1

    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => user1.id,
                                                       :email => 'fooboo@asdfsdf332.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be true

    network_outcome = Network::GetNetworkConnections.run(:account_id => user1.account.first.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "2000"
    expect(network_outcome.result.first.token).to eq "2000"
    expect(network_outcome.result.first.secret).to eq 'secret1'


    # Create another user
    authhash = create_omniauth_hash('twitter', 3000, '3001', 'sec', nil, 'Bowser', 'Bow', "Jones")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'Bow Jones'
    expect(outcome.result.get_user.id).to_not be_nil

    user2 = outcome.result.get_user
    expect(user2.identity.size).to eq 1

    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => user2.id,
                                                       :email => 'bowser@somewhereelse1000.com',
                                                       :password => 'password',
                                                       :site_name => 'mysitebowser')

    expect(update_outcome.success?).to be true
    account = update_outcome.result.second

    network_outcome = Network::GetNetworkConnections.run(:account_id => user2.account.first.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "3000"
    expect(network_outcome.result.first.token).to eq "3001"
    expect(network_outcome.result.first.secret).to eq 'sec'


    # Now have user2 'steal' the identity from the first user1

    authhash = create_omniauth_hash('twitter', 2000, '2002', 'secret3stolen', nil, 'JamesJango', 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'twitterprofile', :aux => 'network_attach'}, :user => user2)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    expect(outcome.result.get_user.user_real_name).to eq 'Bow Jones'
    expect(outcome.result.get_user.id).to_not be_nil
    expect(outcome.result.get_user.id).to eq user2.id
    # Ensure that the identity and network connection from user1 is gone

    expect(user1.identity.blank?).to eq true
    expect(user1.account.first.network_connection.blank?).to eq true

    network_outcome = Network::GetNetworkConnections.run(:account_id => user2.account.first.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 2

    expect(network_outcome.result.first.uid).to eq "3000"
    expect(network_outcome.result.first.token).to eq "3001"
    expect(network_outcome.result.first.secret).to eq 'sec'

    expect(network_outcome.result.second.uid).to eq "2000"
    expect(network_outcome.result.second.token).to eq "2002"
    expect(network_outcome.result.second.secret).to eq 'secret3stolen'

  end

  it 'should attach a facebook page to an account that was created with twitter' do

    authhash = create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango")

    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => nil)
    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :created
    expect(outcome.result.get_user.user_real_name).to eq 'James Jango'
    expect(outcome.result.get_user.id).to_not be_nil

    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    expect(update_outcome.success?).to be true
    expect(update_outcome.result.first.email).to eq 'someone@somewhere97462.com'
    expect(created_user.account.first.site_name).to eq 'mysite'
    account = update_outcome.result.second

    # Now attach a facebook page

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    authhash = create_omniauth_hash('facebook', 2000, '200s', nil, nil, nil, 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'fbpage', :aux => 'network_attach'}, :user => created_user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    created_user_login = outcome.result.get_user
    expect(created_user.id).to eq created_user_login.id

    # Ensure that we have 1 network connections
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "1234"
    expect(network_outcome.result.first.token).to eq "abcd"
    expect(network_outcome.result.first.secret).to eq 'secret'


    FacebookAuthHelper.any_instance.stub(:get_managed_pages) do |args|
      [
          {'id'=> "103", 'name'=> 'JackFruit', 'avatar' => nil, 'access_token' => 'atok1'},
          {'id'=> "203", 'name'=> 'PizzaHut', 'avatar' => nil, 'access_token' => 'atok2'}
      ]
    end

    # Now choose the Facebook page to attach
    pages = Network::GetFacebookPages.run!(:user_id => created_user.id)

    Network::ConnectFacebookPage.run!(:user_id => created_user.id, :account_id => account.id, :fbpage_id => pages.first['id'])

    # Ensure we have 2 network connections now
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 2

    expect(network_outcome.result.first.uid).to eq "1234"
    expect(network_outcome.result.first.token).to eq "abcd"
    expect(network_outcome.result.first.secret).to eq 'secret'

    expect(network_outcome.result.second.uid).to eq "103"
    expect(network_outcome.result.second.token).to eq "atok1"
    expect(network_outcome.result.second.secret).to eq nil


    Network::ConnectFacebookPage.run!(:user_id => created_user.id, :account_id => account.id, :fbpage_id => pages.second['id'])

    # Ensure we have 2 network connections now
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 3

    expect(network_outcome.result.first.uid).to eq "1234"
    expect(network_outcome.result.first.token).to eq "abcd"
    expect(network_outcome.result.first.secret).to eq 'secret'

    expect(network_outcome.result.second.uid).to eq "103"
    expect(network_outcome.result.second.token).to eq "atok1"
    expect(network_outcome.result.second.secret).to eq nil

    expect(network_outcome.result.third.uid).to eq "203"
    expect(network_outcome.result.third.token).to eq "atok2"
    expect(network_outcome.result.third.secret).to eq nil

  end

  it 'should update facebook page tokens on a successful login for all network connections that a user manages through accounts' do

    create_user

    # Create an account
    update_outcome = Accounts::CreateFirstAccountForUser.run(:user_id => @user.id,
                                                             :site_name => 'mysite')
    expect(update_outcome.result.id).to_not be_nil
    account = update_outcome.result

    # Now attach a facebook page

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    authhash = create_omniauth_hash('facebook', 2000, '200s', nil, nil, nil, 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :exists
    created_user_login = outcome.result.get_user
    expect(@user.id).to eq created_user_login.id

    # Ensure that we have 0 network connections
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 0

    FacebookAuthHelper.any_instance.stub(:get_managed_pages) do |args|
      [
          {'id'=> "103", 'name'=> 'JackFruit', 'avatar' => nil, 'access_token' => 'atok1'},
          {'id'=> "203", 'name'=> 'PizzaHut', 'avatar' => nil, 'access_token' => 'atok2'}
      ]
    end

    # Now choose the Facebook page to attach
    pages = Network::GetFacebookPages.run!(:user_id => @user.id)
    Network::ConnectFacebookPage.run!(:user_id => @user.id, :account_id => account.id, :fbpage_id => pages.first['id'])
    # Ensure we have 1 network connection now
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "103"
    expect(network_outcome.result.first.token).to eq "atok1"
    expect(network_outcome.result.first.secret).to eq nil

    # Log the user in again, ensuring that the page tokens get updated

    FacebookAuthHelper.any_instance.stub(:get_managed_pages) do |args|
      [
          {'id'=> "103", 'name'=> 'JackFruit', 'avatar' => nil, 'access_token' => 'REPLACEDatok1'},
          {'id'=> "203", 'name'=> 'PizzaHut', 'avatar' => nil, 'access_token' => 'REPLACEDatok2'}
      ]
    end

    authhash = create_omniauth_hash('facebook', 2000, '200s000', nil, nil, nil, 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {}, :user => @user)

    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    # Verify that the page token was updated after ONLY logging in
    expect(network_outcome.result.first.uid).to eq "103"
    expect(network_outcome.result.first.token).to eq "REPLACEDatok1"
    expect(network_outcome.result.first.secret).to eq nil

  end

  it 'should correctly update an existing facebook page network connection when a second attachment is performed' do

    create_user

    # Create an account
    update_outcome = Accounts::CreateFirstAccountForUser.run(:user_id => @user.id,
                                                             :site_name => 'mysite')
    expect(update_outcome.result.id).to_not be_nil
    account = update_outcome.result

    # Now attach a facebook page

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    authhash = create_omniauth_hash('facebook', 2000, '200s', nil, nil, nil, 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'fbpage', :aux => 'network_attach'}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    created_user_login = outcome.result.get_user
    expect(@user.id).to eq created_user_login.id

    # Ensure that we have 0 network connections
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 0

    FacebookAuthHelper.any_instance.stub(:get_managed_pages) do |args|
      [
          {'id'=> "103", 'name'=> 'JackFruit', 'avatar' => nil, 'access_token' => 'atok1'},
          {'id'=> "203", 'name'=> 'PizzaHut', 'avatar' => nil, 'access_token' => 'atok2'}
      ]
    end

    # Now choose the Facebook page to attach
    pages = Network::GetFacebookPages.run!(:user_id => @user.id)
    Network::ConnectFacebookPage.run!(:user_id => @user.id, :account_id => account.id, :fbpage_id => pages.first['id'])
    # Ensure we have 1 network connection now
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    expect(network_outcome.result.first.uid).to eq "103"
    expect(network_outcome.result.first.token).to eq "atok1"
    expect(network_outcome.result.first.secret).to eq nil

    # Log the user in again, ensuring that the page tokens get updated

    FacebookAuthHelper.any_instance.stub(:get_managed_pages) do |args|
      [
          {'id'=> "103", 'name'=> 'JackFruit', 'avatar' => nil, 'access_token' => 'SECONDATTEMPTatok1'},
          {'id'=> "203", 'name'=> 'PizzaHut', 'avatar' => nil, 'access_token' => 'REPLACEDatok2'}
      ]
    end

    # Attach the connection again
    pages = Network::GetFacebookPages.run!(:user_id => @user.id)
    Network::ConnectFacebookPage.run!(:user_id => @user.id, :account_id => account.id, :fbpage_id => pages.first['id'])

    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    # Verify that the page token was updated after ONLY logging in
    expect(network_outcome.result.first.uid).to eq "103"
    expect(network_outcome.result.first.token).to eq "SECONDATTEMPTatok1"
    expect(network_outcome.result.first.secret).to eq nil

  end

  it 'should correctly update an existing twitter network connection when a second attachment is performed' do

    create_user

    # Create an account
    update_outcome = Accounts::CreateFirstAccountForUser.run(:user_id => @user.id,
                                                             :site_name => 'mysite')
    expect(update_outcome.result.id).to_not be_nil
    account = update_outcome.result

    authhash = create_omniauth_hash('twitter', 2000, '200s', 'twittersecret', nil, 'BobbyJames', 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'twitterprofile', :aux => 'network_attach'}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    created_user_login = outcome.result.get_user
    expect(@user.id).to eq created_user_login.id

    # Ensure that we have 0 network connections
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    # Attempt to attach again
    authhash = create_omniauth_hash('twitter', 2000, '200s2', 'twittersecret2', nil, 'BobbyJames', 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'twitterprofile', :aux => 'network_attach'}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    created_user_login = outcome.result.get_user
    expect(@user.id).to eq created_user_login.id

    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    # Verify that the page token was updated after ONLY logging in
    expect(network_outcome.result.first.uid).to eq "2000"
    expect(network_outcome.result.first.token).to eq "200s2"
    expect(network_outcome.result.first.secret).to eq "twittersecret2"

  end

  it 'should correctly update an existing facebook network connection when a second attachment is performed' do
    create_user

    # Create an account
    update_outcome = Accounts::CreateFirstAccountForUser.run(:user_id => @user.id,
                                                             :site_name => 'mysite')
    expect(update_outcome.result.id).to_not be_nil
    account = update_outcome.result

    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken'
    end

    authhash = create_omniauth_hash('facebook', 2000, '200s', nil, nil, nil, 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'fbprofile', :aux => 'network_attach'}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    created_user_login = outcome.result.get_user
    expect(@user.id).to eq created_user_login.id

    # Ensure that we have 0 network connections
    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    # Attempt to attach again
    UserAuthenticatorService.stub(:exchange_token) do |args|
      'exchangedtoken2'
    end

    authhash = create_omniauth_hash('facebook', 2000, '200s2', nil, nil, nil, 'James', "Jango")
    outcome = Oauth::HandleCallback.run(:auth => authhash, :auth_params => {:account => account.id, :state => 'fbprofile', :aux => 'network_attach'}, :user => @user)

    expect(outcome.success?).to eq true
    expect(outcome.result.get_type).to eq :network_attach
    created_user_login = outcome.result.get_user
    expect(@user.id).to eq created_user_login.id

    network_outcome = Network::GetNetworkConnections.run(:account_id => account.id)
    expect(network_outcome.success?).to eq true
    expect(network_outcome.result.size).to eq 1

    # Verify that the page token was updated after ONLY logging in
    expect(network_outcome.result.first.uid).to eq "2000"
    expect(network_outcome.result.first.token).to eq "exchangedtoken2"
    expect(network_outcome.result.first.secret).to eq nil

  end

  it 'should replenish social tokens for network connections and streams/whatever when reconnecting'

end