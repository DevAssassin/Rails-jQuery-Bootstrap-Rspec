class UserMailer < ActionMailer::Base

  layout "email"

  def invitation(recipient)
    @recipient = recipient
    mail(
      :to => @recipient.email,
      :from => "athletics@scoutforce.com",
      :subject => "You have been invited to ScoutForce"
    ) do |format|
      format.html { render :layout => true }
    end
  end

  def program_added(recipient, programs)
    @recipient = recipient
    @programs = programs
    mail(
      :to => @recipient.email,
      :from => "athletics@scoutforce.com",
      :subject => "You have been added to "+(@programs.count == 1 ? "a new program" : "#{@programs.count} new programs")+" on ScoutForce"
    ) do |format|
      format.html { render :layout => true }
    end
  end

  def account_added(recipient, account)
    @recipient = recipient
    @account = account
    mail(
      :to => @recipient.email,
      :from => "athletics@scoutforce.com",
      :subject => "You have been added to a new account on ScoutForce"
    ) do |format|
      format.html { render :layout => true }
    end
  end

end
