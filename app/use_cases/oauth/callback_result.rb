class Oauth::CallbackResult

  # Pass in an oauth authentication result
  def initialize(auth_result, aux_type)
    @auth_result ||= auth_result
    @aux_type ||= aux_type
  end

  def get_type
    @aux_type
  end

  def get_subtype
    @auth_result.get_subtype
  end

  def get_user
    @auth_result.get_user
  end

  def get_provider
    @auth_result.get_provider
  end
  def get_account
    @auth_result.get_account
  end
  def get_uid
    @auth_result.get_uid
  end
  def get_token
    @auth_result.get_token
  end
  def get_secret
    @auth_result.get_secret
  end
  def get_image
    @auth_result.get_image
  end
end