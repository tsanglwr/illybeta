
class Rebounders::Create < ActiveInteraction::Base

  string :name
  string :account_uuid
  string :specification

  def execute

    service = Rebounder.new(service_uuid: SecureRandom.uuid, name: name, specification: specification, account_uuid: account_uuid)
    service.save!
    service

  end
end


