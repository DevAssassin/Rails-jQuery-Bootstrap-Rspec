class UsersController < ApplicationController
  respond_to :html, :json
  skip_before_filter :authenticate_user!, :only => :invite_sign_up
  skip_before_filter :set_user_state

  def index
    @users = current_scope.associated_users.order_by([:last_name, :asc]).order_by([:first_name, :asc])
  end

  def show
    @user = current_scope.associated_users.find(params[:id])
    respond_with(@user)
  end

  def destroy
    @user = current_scope.associated_users.find(params[:id])
    if current_scope.is_a?(Program)
      @user.remove_program!(current_scope)
    else
      if params[:program_id].blank?
        @user.remove_account!(current_scope)
      else
        program = current_scope.programs.find(params[:program_id])
        @user.remove_program!(program)
      end
    end

    flash[:notice] = "Access revoked for #{@user.name}"
    respond_with(@user, :location => users_path)
  end

  def invite_sign_up
    # TODO: This makes me sad here

    (redirect_to new_user_session_path and return) unless (@user = User.where(:authentication_token => params[:auth_token]).first)
    if params[:user]
      @user.authentication_token = nil
      if @user.update_attributes(params[:user])
        sign_in_and_redirect @user, :force => true
      end
    else
      render :layout => 'basic'
    end
  end

  def invite
    if request.post?
      @invitation = Invitation.new(current_scope, params[:invitation])

      return unless @invitation.valid?

      # call method to check/send email
      user = User.create_and_send_invitation(@invitation)
      if user.recently_invited?
        notice = ["An Invitation Email has been sent to #{user.email}, notifying them that they've been added to:"]
        notice << user.new_account.name if user.new_account
        notice << user.new_programs.collect(&:name) if user.new_programs.size > 0
        notice = notice.join("\n")
      else
        notice = "No invitation sent; #{user.name} already belongs to account/programs selected."
      end
      redirect_to users_path, :notice => notice
    else
      @invitation = Invitation.new(current_scope, params[:invitation])
    end
  end

  def resend_invitations
    @user = current_scope.associated_users.find(params[:id])
    @user.resend_invitations(current_scope)

    flash[:notice] = "Invitations re-sent to #{@user.email}"
    redirect_to users_path
  end

  def verify_cell
    @user = current_user
    if @user.cell_phone_verified?
      flash[:notice] = "Your cell phone number has already been verified"
      redirect_to edit_user_registration_path and return
    end
    response = Twilio::OutgoingCallerId.create(@user.cell_phone, @user.name)
    @code = response['TwilioResponse']['ValidationRequest']['ValidationCode'] rescue nil
    @phone = response['TwilioResponse']['ValidationRequest']['PhoneNumber'] rescue nil
    exception_code = response['TwilioResponse']['RestException']['Code'] rescue "0"
    if exception_code == "21450" # User has already been verified
      redirect_to users_confirm_cell_path
    end
  end

  def confirm_cell
    @user = current_user
    response = Twilio::OutgoingCallerId.list(:PhoneNumber => @user.cell_phone)
    @user.twilio_callerid_sid = response['TwilioResponse']['OutgoingCallerIds']['OutgoingCallerId']['Sid'] rescue nil

    if (@user.twilio_callerid_sid)
      @user.save
      flash[:notice] = "Your cell phone number has been verified"
      redirect_to edit_user_registration_path
    else
      flash[:alert] = "Your cell phone number has not been verified";
      redirect_to users_verify_cell_path
    end
  end

  def unverify_cell
    @user = current_user
    if @user.cell_phone_verified?
      Twilio::OutgoingCallerId.delete(@user.twilio_callerid_sid)
      @user.twilio_callerid_sid = nil;
      @user.save
      flash[:notice] = "Your Caller ID has been reset"
    end
    redirect_to edit_user_registration_path
  end


end
