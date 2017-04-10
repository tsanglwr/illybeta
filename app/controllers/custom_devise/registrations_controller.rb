class CustomDevise::RegistrationsController < Devise::RegistrationsController
  layout 'registrations'
  skip_before_filter :verify_authenticity_token

  def new

    if !current_user.blank?
      redirect_to init_path
      return
    end

    super

  end

  def edit
    super
  end

  def after_sign_up_path_for(resource)
    init_path
  end

end