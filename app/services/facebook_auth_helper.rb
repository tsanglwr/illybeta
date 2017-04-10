class FacebookAuthHelper

  def initialize(user)
    @user ||= user
    identity = Identity.where(:user_id => @user.id, :provider => 'facebook').first

    if identity.nil?
      raise StandardError.new('Facebook auth not found')
    end
    @token = identity.token
    @graph = Koala::Facebook::API.new(@token)
  end

  def get_managed_pages
    pages = []

    results = @graph.get_connections("me", "accounts")

    results.each do |r|
      pic = @graph.get_picture(r['id'])
      pages.push r.merge!({:avatar => pic})
    end

    pages

  end
end