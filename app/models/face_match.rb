class FaceMatch < ActiveRecord::Base

  belongs_to :face_match_result

  has_attached_file :image, :styles=> { :t => "150#", :s => "300x300#", :m => "500x500#"},
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/aws.yml",
                    :s3_protocol => "https",
                    :s3_headers => { :cache_control => 30.days.from_now.httpdate },
                    :bucket => Rails.application.config_for(:s3)['general_bucket']

  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp', 'image/webp'], :message => "has to be in a proper format"

end

