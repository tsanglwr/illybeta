require 'active_resource'
class FaceTemplateEnrolment < ActiveResource::Base
 self.site = Rails.configuration.api_megamatcher_connection[:url]
 self.element_name = "face_template_enrolments"
 self.include_format_in_path = false
end