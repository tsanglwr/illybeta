
class Update < ActiveInteraction::Base

  string :account_uuid
  string :service_uuid
  string :specification
  string :name
  string :subdomain, default: nil

  def execute

    service = Service.find(service_uuid, :params => {account_uuid: account_uuid})
    service.name = @name
    service.specification = @specification
    service.subdomain = @subdomain unless @subdomain.blank?
    service.save!
    service
  end
end


