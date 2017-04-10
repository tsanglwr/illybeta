
class Create < ActiveInteraction::Base

  string :name
  string :account_uuid
  file :image

  def execute

    service = Service.new(service_uuid: SecureRandom.uuid, name: name, specification: specification, account_uuid: account_uuid)
    service.save!
    service

  end
end


