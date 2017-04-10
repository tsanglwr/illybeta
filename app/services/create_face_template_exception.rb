class CreateFaceTemplateException < StandardError

  attr_accessor :error_code

  def initialize(error_code)
    @error_code = error_code
  end

end