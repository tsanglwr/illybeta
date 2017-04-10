class Rebounders::List < ActiveInteraction::Base

  string :account_uuid

  def execute

    objects = Rebounders.all(params: {account_uuid: account_uuid}) #where(account_uuid: account_uuid)

    if objects.nil? || objects.size == 0
      return []
    end

    objects
  end
end
