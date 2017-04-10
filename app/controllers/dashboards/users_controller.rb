class Dashboards::UsersController < ApplicationController
  	before_filter :authenticate_user!
    before_filter :no_guests_allowed
  	layout 'admin'

	before_action :set_user, only: [:show, :edit, :update, :destroy]

	def index
		@users = User.where(:is_admin => 0).order(:first_name, :last_name)

		respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @users }
		end
	end

	def show
		redirect_to edit_admin_user_url
		return

		respond_to do |format|
		  format.html # show.html.erb
		  format.json { render json: @user }
		end
	end
 
	def new
		@user = User.new
	end

 
	def edit
	end

 
	def create
		@user = User.new(user_params)
		password_length = 10
		password = Devise.friendly_token.first(password_length)
		@user.password = password

		respond_to do |format|
		  if @user.save
		    format.html { redirect_to edit_admin_user_url(@user), notice: 'User profile was successfully created.' }
		    format.json { render json: @user, status: :created }
		  else
		    format.html { render action: 'new' }
		    format.json { render json: @user.errors, status: :unprocessable_entity }
		  end
		end
	end
	def update
		respond_to do |format|
		  if @user.update(user_params)

        if user_params.has_key?(:remove_image)
          @user.image = nil
          @user.save
        end

        format.html { redirect_to edit_admin_user_url(@user), notice: 'User profile was successfully updated.' }
		    format.json { head :no_content }
		  else
		    format.html { render action: 'edit' }
		    format.json { render json: @user.errors, status: :unprocessable_entity }
		  end
		end
	end

 
	def destroy

		@user.destroy
		respond_to do |format|
		  format.html { redirect_to admin_users_url }
		  format.json { head :no_content }
		end
	end

	private

	# Use callbacks to share common setup or constraints between actions.
	def set_user
	  @user = User.find(params[:id])
	end
	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
    accessible = [:email, :first_name, :last_name, :phone, :is_phone_public, :is_email_public, :image, :bio, :linkedin_url, :is_profile_hidden, :field_of_study, :remove_image] # extend with your own params
    accessible << [:password, :password_confirmation] unless params[:user][:password].blank?
    params.require(:user).permit(accessible)
	end
end
