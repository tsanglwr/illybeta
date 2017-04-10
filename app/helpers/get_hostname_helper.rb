
module GetHostnameHelper

  # Gets the base URL the server is running at
  def get_base_url

    if Rails.env.production?
      request.protocol + request.host
    else
      request.protocol + request.host_with_port
    end

  end

  def is_ssl?
    request.ssl?
  end

  def get_cdn_base_url
  	Rails.configuration.cdn[:cdn_base]
  end

  def get_cdn_bookmarklet_js_url
    get_cdn_base_url + '/bookmarklet/bookmarklet.js' # The compiled and uploaded bookmarklet code
  end

  def get_cdn_bookmarklet_css_url
    get_cdn_base_url + '/bookmarklet/bookmarklet.css' # The compiled and uploaded bookmarklet code
  end

end