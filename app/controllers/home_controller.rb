# Home
# Responsible for serving up the landing/home page contents
#
class HomeController < ApplicationController
  include GetHostnameHelper

  def pricing
  end

  def about
  end

  def overview
  end

  def pp
  end

  def tos
  end

  def index

    @account_uuid = current_or_guest_account.account_uuid

    @service = Service.new(name: '', specification: '')

  end

  def store

  end
end