# Authentication Result
# Allows client code to determine how the user was authenticated / requesting access
class AuthResult

  #
  # type: Created, Exists, Network_Attach
  # subtype:  Used by Network_Attach; Specifies what type of network attach (ex: twitterprofile, fbprofile, fbpage)
  # provider
  # uid: oauth uuid
  # token: oauth token
  # secret: oauth secret
  # user: user object
  # account: account object
  def initialize(type, subtype, provider, uid, token, secret, image, user, account)

    if type != :created && type != :exists && type != :network_attach && type != :stream_attach
      raise "Unknown auth result type"
    end

    @provider ||= provider
    @type ||= type
    @user ||= user
    @account ||= account
    @uid ||= uid
    @token ||= token
    @secret ||= secret
    @subtype ||= subtype
    @image ||= image
  end

  def get_type
    @type
  end

  def get_subtype
    @subtype
  end

  def get_user
    @user
  end

  def get_provider
    @provider
  end
  def get_account
    @account
  end
  def get_uid
    @uid
  end
  def get_token
    @token
  end
  def get_secret
    @secret
  end
  def get_image
    @image
  end
end

class UserAuthenticatorService

  def initialize(auth, auth_params, user_id, account_id)

    @auth ||= auth
    @auth_params ||= auth_params

    @user_id ||= user_id
    @user = @user_id.nil? ? nil : User.find(@user_id)

    @account_id ||= account_id
    @account = Account.find(@account_id) unless account_id.blank?

  end

  def self.exchange_token(token)
    oauth = Koala::Facebook::OAuth.new(Rails.application.config_for(:social)['facebook_client_key'], Rails..application.config_for(social)['facebook_client_secret'])
    token = oauth.exchange_access_token_info token
    token['access_token']
  end

  def authenticate!

    uid = @auth[:uid]
    provider = @auth[:provider]
    if provider == 'facebook'
      @auth[:credentials][:token] = UserAuthenticatorService.exchange_token(@auth[:credentials][:token]) # Exchange facebook token
    end
    token = @auth[:credentials][:token]
    secret = @auth[:credentials][:secret]
    image = @auth[:info][:image] unless @auth[:info][:image].blank?

    unless image.blank?

      image_url = URI.parse(image.sub("square", "large"))
      image_url.scheme = 'https'
      image = image_url.to_s unless @auth[:image].blank?

    end

    found_user = User.find_user_for_oauth(@auth, @auth_params, @user)

    # User is not found, therefore create it
    if found_user.nil?
      # Create it
      found_user = User.find_or_create_for_oauth(@auth, @auth_params)

      return AuthResult.new(:created, nil, provider, uid, token, secret, image, found_user, nil)
    end

    # User already existed
    if found_user.persisted?

      # A) We would like to attach the network connection to the account
      # User is trying to attach a network profile/page/etc to this account
      if !@auth_params[:aux].blank?
        return AuthResult.new(@auth_params[:aux].to_sym, @auth_params[:state], provider, uid, token, secret, image, found_user, @account)
      else
        return AuthResult.new(:exists, nil, provider, uid, token, secret, image, found_user, @account)
      end

    else
      add_error(:auth, :user_auth_invalid)
    end

  end

end