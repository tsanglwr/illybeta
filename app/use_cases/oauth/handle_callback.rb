module Oauth

  class HandleCallback < Mutations::Command

    required do
      model :auth, class: Hash
    end

    optional do
      model :auth_params, class: Hash, empty: true
      model :user, class: User, empty: true
    end

    def execute

      account_id = inputs[:auth_params][:account]
      auth_service = UserAuthenticatorService.new(inputs[:auth], inputs[:auth_params], inputs[:user].nil? ? nil : inputs[:user].id, account_id)
      auth_result = auth_service.authenticate!
      callback_result = nil # This is what we return

      image = auth_result.get_image
      if !image.blank?
        image_url = URI.parse(image.sub("square", "large"))
        image_url.scheme = 'https'
        image = image_url.to_s
      end

      imageblob = open(image.to_s) unless image.blank?


      # A) We would like to attach the network connection to the account
      # User is trying to attach a network profile/page/etc to this account

      if %w(fbpage twitterprofile fbprofile).include?(inputs[:auth_params][:state]) && inputs[:auth_params][:aux] == 'network_attach'

        callback_result = CallbackResult.new(auth_result, :network_attach)
        # Handle an explicit network attachment, make sure not to handle fbpage here (because the user needs to choose the specific account at higher level up)
        # Result:
        # User + Identity was updated. If this identity was linked to another account, then it was just transferred over
        # Actions:
        # We must check what type of network attachment was requested, then create the appropriate NetworkConnection

        # Attach pages if it is specified or it's a new user (todo)
        #

        case inputs[:auth_params][:state]

          when 'fbprofile'


            Network::CreateUpdateEnsureAssociationOfNetworkConnection.run!(:network => 'facebook',
                                                                           :network_subtype => 'profile',
                                                                           :uid => auth[:uid],
                                                                           :account_id => auth_result.get_account.id,
                                                                           :user_id => auth_result.get_user.id,
                                                                           :handle => auth[:info][:name],
                                                                           :token => auth_result.get_token,
                                                                           :secret => auth_result.get_secret,
                                                                           :image => imageblob)

          when 'fbpage'
            # Handled at another level
          when 'twitterprofile'

            Network::CreateUpdateEnsureAssociationOfNetworkConnection.run!(:network => 'twitter',
                                                                           :network_subtype => 'profile',
                                                                           :uid => auth[:uid],
                                                                           :account_id => auth_result.get_account.id,
                                                                           :user_id => auth_result.get_user.id,
                                                                           :handle => auth[:info][:name],
                                                                           :token => auth_result.get_token,
                                                                           :secret => auth_result.get_secret,
                                                                           :image => imageblob)

          else
            raise ArgumentError.new("Invalid state param")
        end

      elsif !inputs[:auth_params].blank? && %w(fbpage twitterprofile twitterhashtag fbprofile fbhashtag instagramprofile instagramhashtag).include?(inputs[:auth_params][:state]) && inputs[:auth_params][:stream_attach]

        callback_result = CallbackResult.new(auth_result, :stream_attach)

        case inputs[:auth_params][:state]

            when 'fbprofile'

            when 'fbpage'

            when 'twitterprofile'


              Network::CreateUpdateEnsureAssociationOfNetworkCredentialAndStreamSource.run!(:network => 'twitter',
                                                                                            :network_subtype => 'profile',
                                                                                            :uid => auth[:uid],
                                                                                            :account_id => auth_result.get_account.id,
                                                                                            :user_id => auth_result.get_user.id,
                                                                                            :handle => auth[:info][:name],
                                                                                            :token => auth_result.get_token,
                                                                                            :secret => auth_result.get_secret,
                                                                                            :image => imageblob)



            else
              raise ArgumentError.new("Invalid streams attach state param")
          end

      elsif auth_result.get_type == :created
        callback_result = CallbackResult.new(auth_result, :created)
        # The user was JUST created (note that they will not have an account yet, since that is not set up)
        # Result:
        # User + Identity was just created
        # An Account will have to be created
        # Actions: None required at this level, at higher level user must be directed to Account creation screen.
      elsif auth_result.get_type == :exists
        callback_result = CallbackResult.new(auth_result, :exists)
        # They are either logging in or have tried to log in while already logged in
        # Outcome:
        # User + Identity was updated. If this identity was linked to another account, then it was just transferred over
        # Actions:
        # Scan for all network connections for this user and update the token and secret
        #

        Network::CreateUpdateEnsureAssociationOfNetworkConnection.run!(:network => auth_result.get_provider,
                                                                       :network_subtype => 'profile',
                                                                       :uid => auth[:uid],
                                                                       :account_id => auth_result.get_account.blank? ? nil : auth_result.get_account.id,
                                                                       :user_id => auth_result.get_user.id,
                                                                       :handle => auth[:info][:name],
                                                                       :token => auth_result.get_token,
                                                                       :secret => auth_result.get_secret,
                                                                       :image => imageblob)

        # If this is a facebook login, then update any page tokens that the user manages, that may have changed
        if auth_result.get_provider == 'facebook'

          Network::UpdateFacebookPageAuths.run!(:user_id => auth_result.get_user.id)

        end

      else

        raise 'error'
      end

      callback_result

    end
  end
end