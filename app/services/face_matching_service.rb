# connects to face matching API (JDK - MegaMatcher 9)
class FaceMatchingService

  def initialize
  end

  def self.create_face_template_url(image_url)
    m = FaceTemplate.new('imageUrl' => image_url)
    m.save!
    m.faceTemplateUrl

  rescue ActiveResource::BadRequest => e
    parsed_response = JSON.parse(e.response.body)
    f = parsed_response.first
    raise CreateFaceTemplateException.new(parsed_response.first['errorCode'])
  end

  def self.enrol_face_template_url(face_template_url, face_template_uuid)
    m = FaceTemplateEnrolment.new('faceTemplateUrl' => face_template_url, 'faceTemplateUUID' => face_template_uuid)
    m.save!
    m.faceTemplateUUID
  end

  def self.query_face_template_matches(face_template_url)
    m = FaceTemplateMatchQueryRequest.new('faceTemplateUrl' => face_template_url)
    m.save!
    m.matchingFaceTemplateUUIDs
  end
end