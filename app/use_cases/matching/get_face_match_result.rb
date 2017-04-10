class Matching::GetFaceMatchResult < ActiveInteraction::Base

  integer :id

  def execute

    object = FaceMatchResult.find_by_id(@id)
    object

  end
end


