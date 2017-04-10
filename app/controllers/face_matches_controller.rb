class FaceMatchesController < ApplicationController
  include GetHostnameHelper

  def index

    outcome = Matching::GetFaceMatchesByFaceMatchResult.run(face_match_result_id: params[:face_match_result_id])

    if outcome.valid?
      @face_match_result = outcome.result.first
      @face_match_first = outcome.result.second.first
      @face_matches = outcome.result.second
    else
      @face_matches = []
    end

  end

  def show
    outcome = Matching::GetFaceMatchByFaceMatchResultIdAndFaceMatchId.run(face_match_result_id: params[:face_match_result_id], face_match_id: params[:id])

    if outcome.valid?
      @face_match_result = outcome.result.first
      @face_match = outcome.result.second
      @face_match_prev = outcome.result.third
      @face_match_next = outcome.result.fourth
    end
  end

end