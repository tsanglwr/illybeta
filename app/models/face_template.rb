require 'active_resource'
class FaceTemplate < ActiveResource::Base
 self.site = Rails.configuration.api_megamatcher_connection[:url]
 self.element_name = "face_templates"
 self.include_format_in_path = false
 #self.prefix = '/'

end