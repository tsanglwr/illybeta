class User < ActiveRecord::Base
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /change@me/
  has_many :account, :through => :account_manager
  has_many :account_manager
  has_many :identity
  has_many :post
  has_many :product
  has_many :face_match_result

  attr_accessor :remove_image
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update

  has_attached_file :image, :styles=> { :t => "100x100#", :s => "200x200#"},
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/aws.yml",
                    :s3_protocol => "https",
                    :s3_headers => { :cache_control => 30.days.from_now.httpdate },
                    :bucket => Rails.application.config_for(:s3)['general_bucket']

  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp', 'image/webp'], :message => "has to be in a proper format"


  def profile_hidden?
    self.is_profile_hidden == 1
  end

  # The states are:

  # pending -> No videos
  # active -> at least one active video
  # inactive -> at least one video, but none are active
  # expired -> there are only expired videos
  def get_status

    state = 'pending'
    expired = false

    if self.pitch_video.blank?
      state = 'pending'
    end

    self.pitch_video.each do |video|

      # There's at least one active video, therefore this user is active
      vid_status = video.pitch_video_status

      if vid_status.blank?
        next
      end

      if vid_status[0] == 'active'
        state = 'active'
        return [state, 'success']
      elsif vid_status[0] == 'inactive'
        state = 'inactive'
      elsif vid_status[0] == 'expired'
        expired = true
      else
        state = 'inactive'
      end

    end

    if state == 'inactive'
      return ['inactive', 'warning']
    else 
      if expired
        return ['expired', 'danger']
      end
    end

    if state == 'unknown'
      return ['inactive', 'danger']
    end

    return [state, 'primary']

  end

  def get_video_count
    self.pitch_video.size
  end

  def self.find_user_for_oauth(auth, params, signed_in_resource = nil)

    uid = auth[:uid]
    provider = auth[:provider]
    token = auth[:credentials][:token]
    secret = auth[:credentials][:secret]
    image = auth[:info][:image] unless auth[:info][:image].blank?

    if !image.blank?
      image_url = URI.parse(image.sub("square", "large"))
      image_url.scheme = 'https'
      image = image_url.to_s unless image.blank?
    end

    identity = Identity.find_for_oauth(uid, provider, token, secret, auth[:info][:name])
    identity.image = open(image) unless image.blank?
    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
    end
    identity.save!

    user
  end

  def self.find_or_create_for_oauth(auth, params)

    uid = auth[:uid]
    provider = auth[:provider]
    token = auth[:credentials][:token]
    secret = auth[:credentials][:secret]
    image = auth[:info][:image] unless auth[:info][:image].blank?

    if !image.blank?
      image_url = URI.parse(image.sub("square", "large"))
      image_url.scheme = 'https'
      image = image_url.to_s unless image.blank?
    end

    identity = Identity.find_for_oauth(uid, provider, token, secret, auth[:info][:name])
    identity.image = open(image) unless image.blank?

    user = identity.user

    # Create the user if needed
    if user.nil?

      # Create the user if it's a new registration
      user_real_name = ""
      user_name = ""

      if ['facebook'].include?(auth[:provider])
        user_real_name = auth[:info][:name]
      end
      if ['twitter'].include?(auth[:provider])
        user_real_name = auth[:info][:name]
      end
      if ['instagram'].include?(auth[:provider])
        user_real_name = auth[:info][:name]
      end


      user = User.new(
          user_real_name: user_real_name,
          email: "#{TEMP_EMAIL_PREFIX}-#{auth[:uid]}-#{auth[:provider]}.com",
          password: Devise.friendly_token[0, 20]
      )
      user.skip_confirmation!
      user.save!

    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end

    user
  end

  def confirmation_required?
    false
  end


  def manages_account?(account)

    self.account.each do |myaccount|

      if myaccount.id == account.id
        return true
      end
    end

    return false

  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end

  def self.generate_guest_email
    "guest_#{Time.now.to_i}_#{rand(10000)}_change@me"
  end
end

