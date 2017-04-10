
class Rebounders::Get < ActiveInteraction::Base

  string :account_uuid
  string :rebounder_uuid

  def execute

    object = Rebounder.find(rebounder_uuid, :params => {account_uuid: account_uuid})
    object

  end
end


