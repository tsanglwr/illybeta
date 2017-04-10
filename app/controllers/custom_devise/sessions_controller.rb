class CustomDevise::SessionsController < Devise::SessionsController
  layout 'registrations'

  def new
    super
  end

  def after_sign_in_path_for(resource)
    init_path
  end

end