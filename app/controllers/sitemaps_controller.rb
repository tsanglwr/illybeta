class SitemapsController < ApplicationController
  def index
    @static_pages = [root_url]

    respond_to do |format|
      format.xml
    end
  end
end