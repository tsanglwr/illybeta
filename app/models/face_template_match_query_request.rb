require 'active_resource'
class FaceTemplateMatchQueryRequest < ActiveResource::Base
 self.site = Rails.configuration.api_megamatcher_connection[:url]
 self.element_name = "face_template_match_query_requests"
 self.include_format_in_path = false
end