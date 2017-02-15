class SignUpMailer < ActionMailer::Base
  #default :from => "redmine@sproutify.com"
  default :to => [ "tech@scoutforce.com", "sales@scoutforce.com" ]

  def unsupported_sport_notification(sign_up)
    @sign_up = sign_up
    mail(:subject => "Unsupported Sport Account Sign up", :from => @sign_up.email)
  end

  def unknown_account_program(email)
    @email = email
    mail(:subject => "Unknown Account and Program Signup")
  end

  def thank_you_for_unsupported_sport(email)
    mail(:to => email, :subject => "Thank you for signing up.")
  end

  def signup(sign_up)
    @sign_up = sign_up
    mail(:subject => "Sign Up Step 1 Completed", :from => sign_up.email)
  end
end

