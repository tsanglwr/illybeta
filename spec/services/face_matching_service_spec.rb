require 'rails_helper'
require 'spec_helper'

describe FaceMatchingService do

  it 'should successfully create face template url from image url' do

    outcome = Oauth::HandleCallback.run(:auth => create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango"), :auth_params => {}, :user => nil)
    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    image_file = File.new(Rails.root + 'spec/use_cases/test_assets/charlie-sheen.jpg')
    outcome = Matching::CreateFaceMatchResult.run(user_id: created_user.id, account_uuid: created_user.account.first.account_uuid, image: image_file)
    face_match_result = outcome.result

    face_matching_service = FaceMatchingService.new
    source_image_url = face_match_result.image.url
    face_template_url = FaceMatchingService.create_face_template_url(source_image_url)

    expect(face_template_url).to_not be_nil
  end

  it 'should successfully enrol face template url' do

    outcome = Oauth::HandleCallback.run(:auth => create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango"), :auth_params => {}, :user => nil)
    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    image_file = File.new(Rails.root + 'spec/use_cases/test_assets/charlie-sheen.jpg')
    outcome = Matching::CreateFaceMatchResult.run(user_id: created_user.id, account_uuid: created_user.account.first.account_uuid, image: image_file)
    face_match_result = outcome.result

    face_matching_service = FaceMatchingService.new

    source_image_url = face_match_result.image.url
    face_template_url = FaceMatchingService.create_face_template_url(source_image_url)
    expect(face_template_url).to_not be_nil

    uuid = SecureRandom.uuid
    original_face_template_uuid = FaceMatchingService.enrol_face_template_url(face_template_url, uuid)
    expect(original_face_template_uuid).to_not be_nil
    expect(original_face_template_uuid).to eq uuid
  end

  it 'should successfully perform basic match' do
    outcome = Oauth::HandleCallback.run(:auth => create_omniauth_hash('twitter', 1234, 'abcd', 'secret', nil, 'James9009', 'James', "Jango"), :auth_params => {}, :user => nil)
    created_user = outcome.result.get_user

    # Create an account
    update_outcome = Accounts::SetupUserAndAccount.run(:user_id => created_user.id,
                                                       :email => 'someone@somewhere97462.com',
                                                       :password => 'password',
                                                       :site_name => 'mysite')

    image_file = File.new(Rails.root + 'spec/use_cases/test_assets/charlie-sheen.jpg')
    outcome = Matching::CreateFaceMatchResult.run(user_id: created_user.id, account_uuid: created_user.account.first.account_uuid, image: image_file)
    face_match_result = outcome.result

    face_matching_service = FaceMatchingService.new

    source_image_url = face_match_result.image.url
    face_template_url = FaceMatchingService.create_face_template_url(source_image_url)
    expect(face_template_url).to_not be_nil

    uuid = SecureRandom.uuid
    original_face_template_uuid = FaceMatchingService.enrol_face_template_url(face_template_url, uuid)
    expect(original_face_template_uuid).to_not be_nil
    expect(original_face_template_uuid).to eq uuid

    query_face_template_result = FaceMatchingService.query_face_template_matches(face_template_url)
    expect(query_face_template_result).to_not be_nil
    expect(query_face_template_result.size > 0).to eq true
  end

end