class RegistrationsController < Devise::RegistrationsController

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to edit_user_registration_path, :notice => 'Account successfully updated !'
    else
      render 'edit'
    end
  end

  def change_email_password
    @user = current_user
    if params[:user] && @user.update_with_password(params[:user],@user.email)
      redirect_to edit_user_registration_path, :notice => 'Successfully saved !'
    end
  end
  
  #Registration Plans
  def plans
    render 'register_plans'
  end
  
  def plan
    plan_name = params[:plan_name] || "basic"
    @registration_plans = User.new(:plan => plan_name)
  end
  
  def payment
    recurly_domain = Rails.env.production? ? "scoutforce.recurly.com" : 'scoutforce-test.recurly.com'
    @sign_up = User.new(params[:user])

    if @sign_up.save
      @sign_up.send_signup_email

      redirect_to("https://#{recurly_domain}/subscribe/#{@sign_up.plan}?first_name=#{@sign_up.first_name}&last_name=#{@sign_up.last_name}&email=#{CGI::escape(@sign_up.email)}")
    else
      render 'plan'
    end
  end

end
