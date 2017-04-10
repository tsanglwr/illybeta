class Matching::GetFaceMatchesByFaceMatchResult < ActiveInteraction::Base

  integer :face_match_result_id

  def execute

    object = FaceMatchResult.find_by_id(@face_match_result_id)

    face_matches = FaceMatch.where('face_match_result_id = ?', @face_match_result_id).order(score_percent: :asc, id: :asc).all
    [object, face_matches]

  end
end


