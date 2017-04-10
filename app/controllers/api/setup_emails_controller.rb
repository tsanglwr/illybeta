class Api::SetupEmailsController < ApplicationController

  respond_to :json

  def exists

    outcome = Api::GetEmailInUse.run(:email => params[:email])

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
