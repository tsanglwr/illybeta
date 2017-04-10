class Api::ApiNewsletterSubscriptionsController < ApplicationController

  respond_to :json

  def create

    outcome = Api::NewsletterSubscribe.run(:email => params[:email], :list_id => Rails.configuration.mailchimp[:list_id])

    if outcome.success?
      render json: outcome.result, status: 200
    elsif outcome.errors.symbolic[:email] == :empty
      render json: {:error => outcome.errors[:email]}.to_json, status: 422
    else
      render json: {:error => outcome.errors.message_list.join(',')}.to_json, status: 500
    end

  end

end

