class Api::SetupValidatorController < ApplicationController

  respond_to :json

  def validate

    # Site name unique ness

    if !params[:user].blank? && !params[:user][:account_manager].blank? && !params[:user][:account_manager][:account].blank? && !params[:user][:account_manager][:account][:site_name].blank?

      outcome = Api::GetSitenameInUse.run(:sitename => params[:user][:account_manager][:account][:site_name])

      if outcome.success?

        if outcome.result
          render json: outcome.result, status: 200
        else
          render json: outcome.result, status: 404
        end

      else
        render json: {:error => outcome.errors.message_list.join(',')}.to_json, status: 500
      end

    end

  if !params[:user][:email].blank?
    # Email uniqueness
    outcome = Api::GetEmailInUse.run(:email => params[:user][:email])

    if outcome.success?

      if outcome.result
        render json: outcome.result, status: 200
      else
        render json: outcome.result, status: 404
      end

    else
      render json: {:error => outcome.errors.message_list.join(',')}.to_json, status: 500
    end
  end



  end

end
