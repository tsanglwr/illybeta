class FaceMatchResult < ActiveRecord::Base

  has_many :face_match

  has_attached_file :image, :styles=> { :t => "150#", :s => "300x300#", :m => "500x500#"},
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/aws.yml",
                    :s3_protocol => "https",
                    :s3_headers => { :cache_control => 30.days.from_now.httpdate },
                    :bucket => Rails.application.config_for(:s3)['general_bucket']

  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp', 'image/webp'], :message => "has to be in a proper format"

  def is_processing_completed?
    self.is_processing_completed == 1
  end

  def is_error?
    self.is_error == 1
  end

  def get_error_code
    self.error_code
  end

  def get_error

    case self.error_code
      when 'OBJECT_NOT_FOUND'
        'Failed to process image'
      when 'BAD_SHARPNESS'
        'Image quality is not sharp enough'
      else
        self.error_code
    end

  end

end

