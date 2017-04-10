class ActivityStreamController < ApplicationController
  layout 'dashboards'
  protect_from_forgery with: :null_session
  before_filter :authenticate_user!

  def index
    @account_uuid = current_or_guest_account.account_uuid

  end

  def show
    @account_uuid = current_or_guest_account.account_uuid

  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def rebounder_params
    params.require(:rebounder).permit(:name, :specification, :subdomain)
  end
end
