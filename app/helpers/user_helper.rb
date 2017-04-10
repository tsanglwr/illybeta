
module UserHelper

	def setup_user(user)
		user.account ||= Account.new
		user
	end

  def setup_user_account_for_test(user)
    site_name = SecureRandom.uuid.to_s
    Accounts::CreateFirstAccountForUser.run!(:user_id => user.id, :site_name => site_name)
  end

	# After the user has initialized (setup_site / logged in / Created account)
	# ...redirect them somewhere that makes sense for THIS APP
	def path_after_init(user, account)
		redirect_to dashboard_activity_stream_index_path(account_uuid: account.account_uuid)
	end

end