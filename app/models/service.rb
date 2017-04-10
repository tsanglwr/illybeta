require 'active_resource'
class Service < ActiveResource::Base
  self.site = Rails.configuration.api_megamatcher_connection[:url]
  self.prefix = '/manage/v1/accounts/:account_uuid/'

  #fortify :name, :specification, :service_uuid
end