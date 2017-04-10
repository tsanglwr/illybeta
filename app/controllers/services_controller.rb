class ServicesController < ApplicationController
  layout 'dashboards'
  protect_from_forgery with: :null_session
  def index
    @account_uuid = current_or_guest_account.account_uuid
    @services = List.run!(account_uuid: current_or_guest_account.account_uuid)
  end

  def show
    @account_uuid = current_or_guest_account.account_uuid
    @service = GetService.run!(account_uuid: @account_uuid, service_uuid: params[:id])
  end

  def new
    @account_uuid = current_or_guest_account.account_uuid
    @service = Service.build(account_uuid: @account_uuid)
  end

  def edit
    @account_uuid = current_or_guest_account.account_uuid
    @service = GetService.run!(account_uuid: @account_uuid, service_uuid: params[:id])
  end

  def update
    @account_uuid = current_or_guest_account.account_uuid
    @service = Update.run!(account_uuid: @account_uuid,
                                  service_uuid: params[:id],
                                  specification: service_params[:specification],
                                  subdomain: service_params[:subdomain],
                                  name: service_params[:name])

    redirect_to dashboard_service_path(@account_uuid, @service.service_uuid)
  end

  def create
    @account_uuid = current_or_guest_account.account_uuid
    outcome = Create.run(account_uuid: @account_uuid, name: service_params[:name], specification: service_params[:specification])

    respond_to do |format|
      if outcome.valid?
        format.html { redirect_to dashboard_service_path(outcome.result.service_uuid, account_uuid: @account_uuid), notice: 'Service successfully created' }
        format.json { render json: outcome.result, status: :created }
      else
        format.html { render action: 'edit' }
        format.json { render json: outcome.errors.full_messages.to_sentence, status: :unprocessable_entity }
      end
    end

  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def service_params
    params.require(:service).permit(:name, :specification, :subdomain)
  end
end
