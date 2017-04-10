require 'RMagick'
include Magick

class ShareLink < ActiveRecord::Base
  include GetHostnameHelper
  #include ShareLinksHelper
  belongs_to :video
  after_create :after_create

  has_attached_file :qrcode,
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/aws.yml",
                    :s3_protocol => "https",
                    :s3_headers => { :cache_control => 30.days.from_now.httpdate },
                    :bucket => Rails.application.config_for(:s3)['general_bucket']

  validates_attachment_content_type :qrcode, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp', 'image/webp'], :message => "has to be in a proper format"

  # Generate a QR code after creating this link

  def after_create
    # Save the bare QR code in an PNG image
    qr = RQRCode::QRCode.new(link_for_share_link_safe(self), :size => 8, :level => :h )
    png = qr.as_png # returns an instance of ChunkyPNG
    qr_name = 'qr-' + self.pitch_video.user.email + '-' + self.pitch_video.title + Time.now.to_i.to_s + '.png'

    bare_qr_code_path = "#{Rails.root}/tmp/" + qr_name
    appended_output_file_path = nil
    begin
      # Write the bare QR code to a file/image
      temp_file = File.open(bare_qr_code_path, 'wb') { |io| png.write(io) }
      # Grab the image to append
      image_list = ImageList.new(temp_file.path, "#{Rails.root}/app/assets/images/seepitch_addon.png")
      resulting_appended_image = image_list.append(true)
      # Read the qr code
      appended_output_file_path = "#{Rails.root}/tmp/" + 'append_' + qr_name
      resulting_appended_image.write appended_output_file_path
      self.qrcode =  File.open(appended_output_file_path) #image_list.to_blob #File.open(temp_file.path)
      self.save
    ensure
      File.unlink(bare_qr_code_path)# cleanup the temp file...
      File.unlink(appended_output_file_path)# cleanup the temp file...
    end

  end

  def self.get_stats(share_link)

    outcome = Pitches::GetPitchAnalyticsData.run(:unique_key => share_link.unique_key)

    if outcome.success?
      return outcome.result
    else
      return {:total => 0, :unique => 0}
    end

  end

end
