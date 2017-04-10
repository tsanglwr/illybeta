class Matching::CreateFaceMatchResult < ActiveInteraction::Base

  integer :user_id
  file :image

  def execute

    object = FaceMatchResult.new(user_id: user_id, image: @image, face_match_result_uuid: SecureRandom.uuid, image_sha256: Digest::SHA256.hexdigest(@image.read))
    object.save!

    ProcessPhotoUploadJob.perform_later object
    object
  end
end


