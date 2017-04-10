require 'rails_helper'
require 'spec_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe GetService do

  it 'should not get service with no service uuid' do

    s = GetService.run!(service_uuid: "service", account_uuid: "account")
    s
  fail
  end

end