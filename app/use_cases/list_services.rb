class List < ActiveInteraction::Base

  integer :face_match_result_id

  def execute

    i = @face_match_result_id

    face_matches = Matching::GetFaceMatchResult.run(face_match_result_id: @face_match_result_id)
    services = Service.all(params: {account_uuid: account_uuid})

    if services.nil? || services.size == 0
      return []
    end

    services
  end
end
