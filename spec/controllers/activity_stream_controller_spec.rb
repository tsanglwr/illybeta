require 'rails_helper'
require 'spec_helper'

describe ActivityStreamController do

  include UserHelper

  context 'As User Agent' do

    before do
      # other_subdomain = "subdom"
      # @request.host = "#{other_subdomain}.example.com"
    end

    it 'should successfully create or update rebounder', :type => :request do

      user = FactoryGirl.create(:user)
      sign_in user
      setup_user_account_for_test(user)

      # Create some new pets and expect to get them
      params = {
          'code' => 'function() { console.log(1); }',
          'url' => nil
      }

      # url?callback=https://callbackurl.com/foo/bar?
      request_headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
      }

      container_uuid = SecureRandom.uuid
      ua = user.account

      account_uuid = user.account.first.account_uuid
      post "http://localhost.dev/dashboards/#{account_uuid}/rebounders", params.to_json, request_headers

      response_body = response.body
      parsed = JSON.parse(response.body)
      expect(response.status).to eq 200



    end

  end
end


