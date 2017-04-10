
class GetService < ActiveInteraction::Base

  string :account_uuid
  string :service_uuid

  def execute

    service = Service.find(service_uuid, :params => {account_uuid: account_uuid})
    service

  end
end


