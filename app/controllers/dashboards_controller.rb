class DashboardsController < ApplicationController

  def index
  end

  def base
    redirect_to dashboard_activity_stream_path(account_uuid: current_or_guest_account.account_uuid)
  end

end