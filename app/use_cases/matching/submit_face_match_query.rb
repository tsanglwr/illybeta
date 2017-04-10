class Matching::SubmitFaceMatchQuery < ActiveInteraction::Base

  integer :face_match_result_id

  def execute
    face_match_result = FaceMatchResult.find_by_id(@face_match_result_id)

    face_template_url = nil
    begin
      face_template_url = FaceMatchingService.create_face_template_url(face_match_result.image.url)
    rescue => e
      face_match_result.is_processing_completed = 1
      face_match_result.is_error = 1
      face_match_result.error_code = e.error_code
      face_match_result.save
      self.errors.add(:face_match_result_id, e.to_s)
      return
    end

    FaceMatchingService.enrol_face_template_url(face_template_url, face_match_result.face_match_result_uuid)
    face_template_matches = FaceMatchingService.query_face_template_matches(face_template_url)

    existing_image_sha256 = {}

    face_template_matches.each do |match|
      matched_result = FaceMatchResult.where(:face_match_result_uuid => match.faceTemplateUUID).first
      next if matched_result.blank? || matched_result.id == face_match_result

      if !existing_image_sha256[matched_result.image_sha256].blank?
        next
      end
      existing_image_sha256[matched_result.image_sha256] = matched_result.image_sha256
      face_match = FaceMatch.new(:face_match_result_id => face_match_result.id, :matched_with_face_match_result_id => matched_result.id)
      face_match.image = matched_result.image.url
      face_match.score_percent = match.matchScore
      face_match.save!
    end

    face_match_result = FaceMatchResult.find_by_id(@face_match_result_id)
    face_match_result.is_processing_completed = 1
    face_match_result.save!
    face_match_result
  end
end


