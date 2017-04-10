class ProcessPhotoUploadJob < ActiveJob::Base
  queue_as :default

  def perform(*args)

    face_match_result = args.first
    outcome = Matching::SubmitFaceMatchQuery.run(face_match_result_id: face_match_result.id)

  end
end
