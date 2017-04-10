class Accounts::LoggingIn < ActiveInteraction::Base

  integer :guest_user_id
  integer :current_user_id
  string :specification, default: nil

  def execute
  guest_user = User.find_by_id(@guest_user_id)
   face_match_results = guest_user.face_match_result.all

   face_match_results.each do |face_match_result|
     face_match_result.user_id = @current_user_id
     face_match_result.save!
   end

  end
end


