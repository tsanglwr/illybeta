# Init
#
# Init is a controlled entry point that ensures the following:
#
# * Current_or_guest_user is available and has valid session
# * Redirects to dashboard if current_or_guest_user
# * Checks to make sure that the current_or_guest_user has at least 1 accont to manage
#
class InitController < ApplicationController
  include UserHelper

  before_filter :set_owned_accounts, :except => [:index]

  # Setup the account on initial use -- or if no accounts are managed by the user
  # Check if the user has any accounts associated
  def index

    current_or_guest_user
    # Preempt
    #redirect_to dashboard_apis_path
    #return

    if current_user.blank?
      redirect_to root_path
      return
    end

    # Does the user have a valid email + password?
    # No => Collect email + password
    # Yes => No need to collect email + password

    credentials_set = current_user.email_verified?

    # Does the user manage any accounts?
    # No => Collect a site name
    # Yes => No need to collect site name

    manages_site = false

    accounts = current_user.account
    if !current_user.account.nil? && current_user.account.size > 0
      manages_site = true
    end

    # If user has valid email + password and there is at least 1 account the user manages
    # Then redirect to managing the default/first site

    if credentials_set && manages_site
      account = accounts.first
      path_after_init(current_user, account)
      return
    end

    if credentials_set
      redirect_to setup_site_path(current_user.id)
      return
    else
      redirect_to setup_path(current_user.id)
      return
    end
  end

end