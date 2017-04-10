# Main application entry
#
# Sets up:
#
# * CORS headers and preflight (for Fonts and CDNs)
# * Common JS facilities (to pass data from controller to view jS later elegantly (via gon js))
# * Initialization of the guest or signed in user
#
class ApplicationController < ActionController::Base
  include GetHostnameHelper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :include_js_setup_vars, :cors_preflight_check
  after_filter :cors_set_access_control_headers

  # For all responses in this controller, return the CORS access control headers.
  # **Important for Fonts and Asset delivery over CDN**
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.
  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = '*'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end
   
  # Include JS setup variables
  def include_js_setup_vars
    gon.is_production = Rails.env.production?
    gon.fqdn = request.host_with_port
    gon.facebook_app_id = Rails.configuration.oauth[:facebook_app_id]
    gon.twitter_app_id = Rails.configuration.oauth[:twitter_app_id]
    @facebook_app_id = gon.facebook_app_id
    @twitter_app_id = gon.twitter_app_id
  end

  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    if current_user
      if session[:guest_user_id] && session[:guest_user_id] != current_user.id
        logging_in
        guest_user(with_retry = false).try(:destroy)
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_account
    account = Accounts::GetOrCreateFirstAccountForUser.run!(:user_id => current_or_guest_user.id, :site_name => SecureRandom.uuid.to_s)

    account
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user(with_retry = true)
    # Cache the value the first time it's gotten.
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

  rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
     session[:guest_user_id] = nil
     guest_user if with_retry
  end

  private

  # called (once) when the user logs in, insert any code your application needs
  # to hand off from guest_user to current_user.
  def logging_in
    Accounts::LoggingIn.run(:guest_user_id => guest_user.id, :current_user_id => current_user.id)
  end

  def create_guest_user
    u = User.create(:email => User.generate_guest_email)
    u.save!(:validate => false)
    session[:guest_user_id] = u.id
    u
  end

  def guest?
    session[:guest_user_id] != nil
  end

  def no_guests_allowed
    if guest?
      flash[:error] = 'Sorry, but you do not have access to that'
      redirect_to root_path
    end
  end

  def resource_name
    :user
  end

  def resource_class
    User
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  helper_method :current_or_guest_user
  helper_method :guest?
 
end
