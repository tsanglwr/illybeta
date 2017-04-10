
class Rebounders::Update < ActiveInteraction::Base

  string :account_uuid
  string :rebounder_uuid
  string :specification
  string :name
  string :subdomain, default: nil

  def execute

    service = Rebounder.find(service_uuid, :params => {account_uuid: account_uuid})
    service.name = @name
    service.specification = @specification
    service.subdomain = @subdomain unless @subdomain.blank?
    service.save!
    service
  end
end


