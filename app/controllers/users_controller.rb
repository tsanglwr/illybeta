class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :setup, :setup_site]
  include UserHelper
  layout 'dashboards'

  def index
    i = 1
  end
  # GET /users/:id.:format
  def show
    # authorize! :read, @user
  end

  # GET /users/:id/edit
  def edit
    # authorize! :update, @user
   # render :layout => 'admin'

  end

  # PATCH/PUT /users/:id.:format
  def update
    raise false
    # authorize! :update, @user
    respond_to do |format|
      if @user.update(user_params)

        sign_in(@user == current_user ? @user : current_user, :bypass => true)
        format.html { redirect_to @user, notice: 'Your profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET/PATCH /users/:id/setup
  def setup

    # authorize! :update, @user
    if request.patch? && params[:user] # && params[:user][:email] && !params[:user][:password].blank?
      site_name = params[:user][:account_manager][:account][:site_name]
      update_outcome = Accounts::SetupUserAndAccount.run(:user_id => params[:id], :email => params[:user][:email], :password => params[:user][:password], :site_name => site_name)

      if update_outcome.success?
        user = update_outcome.result.first

        sign_in(user, :bypass => true)
        account = update_outcome.result.second

        path_after_init(user, account)
        return

      else
        @show_errors = true
        flash[:error] = update_outcome.errors.message_list
      end

    end

    render :layout => 'initial_setup'
  end

  def setup_site

    # Set to true if you do not want the user to see the 'choose site name' screen
    # It will auto assign a random uuid for the site name and allow the user to seamlessly move on
    # Set it to false if you want control over the sign in flow
    auto_setup_site = true

    # authorize! :update, @user
    if auto_setup_site || request.patch? #&& params[:user][:email]
      # User email + password has been confirmed and set already
      # Create the new site
      site_name = SecureRandom.uuid.to_s
      site_name = params[:user][:account_manager][:account][:site_name] unless auto_setup_site
      outcome = Accounts::CreateFirstAccountForUser.run(:user_id => current_user.id, :site_name => site_name)

      if !outcome.success?
        @show_errors = true
        flash[:error] = outcome.errors.message_list.join(",")
      else
        account = outcome.result
        path_after_init(current_user, account)
        return
      end
    end

    render :layout => 'initial_setup'
  end


  # DELETE /users/:id.:format
  def destroy
    # authorize! :delete, @user
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  private
  def set_user

    begin
      @user = User.find(params[:id])

      if @user.id != current_user.id
        sign_out current_user
        redirect_to root_path
      end
    rescue ActiveRecord::RecordNotFound => e
      sign_out :user
      redirect_to root_path
    end

  end

  def user_params
    accessible = [:name, :email, :remove_avatar] # extend with your own params
    accessible << [:password, :password_confirmation] unless params[:user][:password].blank?
    params.require(:user).permit(accessible)
  end
end
