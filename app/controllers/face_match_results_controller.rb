class FaceMatchResultsController < ApplicationController
  include GetHostnameHelper
  protect_from_forgery with: :null_session

  def create
    @account_uuid = current_or_guest_account.account_uuid
    outcome = Matching::CreateFaceMatchResult.run(user_id: current_or_guest_user.id, account_uuid: @account_uuid, image: params[:face_match_result][:image])

    respond_to do |format|
      if outcome.valid?
        format.html { redirect_to face_match_result_processing_path(outcome.result.id)}
        format.json { render json: outcome.result, status: :created }
      else
        format.html { redirect_to root_path, :notice => 'Error, please try again' }
        format.json { render json: outcome.errors.full_messages.to_sentence, status: :unprocessable_entity }
      end
    end
  end

  def processing

    outcome = Matching::GetFaceMatchResult.run(id: params[:id])

    if outcome.valid?
      if outcome.result.is_processing_completed? && !outcome.result.is_error?
        redirect_to face_match_result_path(outcome.result.id)
        @object = outcome.result
      elsif outcome.result.is_processing_completed? && outcome.result.is_error?
        redirect_to root_path, :notice => 'An error occurred: ' + outcome.result.get_error
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, :notice => 'Error, please try again' }
        format.json { render json: outcome.errors.full_messages.to_sentence, status: :unprocessable_entity }
      end
    end
  end

  def show

    @face_match_result_id = params[:id]
    outcome = Matching::GetFaceMatchResult.run(id: params[:id])
    @object = outcome.result

    redirect_to face_match_result_face_matches_path(@face_match_result_id)
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end


end