class Admin::UsersController < AdminController
  respond_to :html, :json
  respond_to :csv, :only => :index

  def invite
    @program = current_program
    @account = current_account
    if @program
      render 'program_invite'
    else
      render 'account_invite'
    end
  end

  def send_invite
    email = params[:email]

    @program = current_program
    @account = current_account

    user = User.find_or_initialize_by(email: email.downcase)

    if @program
      user.invite(programs: [@program])
    elsif @account
      user.invite(account: @account)
    end

    flash[:notice] = "Invite sent"

    redirect_to [:admin, @account]
  end

  def index
    @users = current_scope ? current_scope.associated_users.by_last_name : User.by_last_name
    respond_with @users
  end

  def show
    respond_with @user = User.find(params[:id])
  end

  def new
    respond_with @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    flash[:notice] = 'User was successfully created.' if @user.save
    respond_with [:admin, @user]
  end

  def update
    @user = User.find(params[:id])
    flash[:notice] = 'Admin::User was successfully updated.' if @user.update_attributes(params[:user])
    respond_with [:admin, @user]
  end

  #this removes a user from an account, or program depending on the scope
  def destroy
    if current_scope.is_a?(Program)
      @user = current_scope.associated_users.find(params[:id])
      @user.remove_program!(current_scope)
      flash[:notice] = "Access revoked for #{@user}"
    else
      @user = current_scope.associated_users.find(params[:id])
      @user.remove_account!(current_scope)
      flash[:notice] = "Access revoked for #{@user}"
    end

    respond_with [:admin, @user]
  end

  def become
    sign_in(:user, User.find(params[:id]))
    session[:scope_id] = nil #we want the scope to be reset to the user's default scope
    redirect_to root_url
  end

  def reset_password
    @user = User.find(params[:id])
    email = @user.send_reset_password_instructions
    render :text => email.body
  end

  def resend_invitations
    @user = User.find(params[:id])
    @user.resend_invitations(current_scope)

    flash[:notice] = "Invitations re-sent to #{@user.email}"
    redirect_to users_path
  end
end
