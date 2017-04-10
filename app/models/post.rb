class Post < ActiveRecord::Base
	belongs_to :user
	#mount_uploader :file, PitchVideoUploader
	#validates_presence_of :file
	before_save :before_save
  before_create :before_create

	has_attached_file :logo, :styles=> { :t => "100x100#", :s => "200x200#", :l => "400x400"},
	                    :storage => :s3,
	                    :s3_credentials => "#{Rails.root}/config/aws.yml",
	                    :s3_protocol => "https",
	                    :s3_headers => { :cache_control => 30.days.from_now.httpdate },
	                    :bucket => Rails.application.config_for(:s3)['general_bucket']
	has_attached_file :banner, :styles=> { :t => "100x100#", :s => "<400", :l => "<800"},
	                    :storage => :s3,
	                    :s3_credentials => "#{Rails.root}/config/aws.yml",
	                    :s3_protocol => "https",
	                    :s3_headers => { :cache_control => 30.days.from_now.httpdate },
	                    :bucket => Rails.application.config_for(:s3)['general_bucket']


	validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp', 'image/webp'], :message => "has to be in a proper format"

	validates_attachment_content_type :banner, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp', 'image/webp'], :message => "has to be in a proper format"


	def before_create
		self.unique_key = Post.generate_unique_key
  	end

	def before_save
 
	end
	
	# Generate a unique key that no other pitch videos have
	def self.generate_unique_key

	  smallest_key_length = 12
	  alphanumcase = ('a'..'z').to_a + ('A'..'Z').to_a

	  # character set to chose from:
	  #  :alphanum     - a-z0-9     -  has about 60 million possible combos
	  #  :alphanumcase - a-zA-Z0-9  -  has about 900 million possible combos

	  # not doing uppercase as url is case insensitive
	  charset = alphanumcase
	  
	  uq = (0...smallest_key_length).map { charset[rand(charset.size)] }.join

	  # Try up to 10 times to acquire a unique key
	  for i in 0..5

	  	found = Post.where(:unique_key => uq).first
	  	# Not found with this key, therefore we can return this as a unique key
	  	if found.nil?
	  		return uq
	  	end

	  end

	  raise ArgumentError.new('Unable to generate unique key for Pitch Video')

	end

end
