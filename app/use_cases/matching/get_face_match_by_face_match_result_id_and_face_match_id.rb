class Matching::GetFaceMatchByFaceMatchResultIdAndFaceMatchId < ActiveInteraction::Base

  integer :face_match_result_id
  integer :face_match_id

  def execute

    face_match_result = FaceMatchResult.find_by_id(@face_match_result_id)
    face_match = FaceMatch.find_by_id(@face_match_id)
    face_match_prev = FaceMatch.where('(score_percent < ? OR id < ?) AND face_match_result_id = ?', face_match.score_percent, face_match.id, @face_match_result_id).order(score_percent: :asc, id: :asc).last
    face_match_next = FaceMatch.where('(score_percent > ? OR id > ?) AND face_match_result_id = ?', face_match.score_percent, face_match.id, @face_match_result_id).order(score_percent: :asc, id: :asc).first
    [face_match_result, face_match, face_match_prev, face_match_next]

  end
end


