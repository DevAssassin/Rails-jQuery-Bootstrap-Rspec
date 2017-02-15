class AlumnusFormMailer < ActionMailer::Base
  layout "email"

  def online_create_notification(recipient_email, alumnus)
    @alumnus = alumnus
    attachments.inline['alumnus.jpg'] = File.read(@alumnus.photo.url(:thumb)) if @alumnus.photo.url
    mail(
      :to => recipient_email,
      :from => "athletics@scoutforce.com",
      :subject => "An Alumnus has just created a profile on ScoutForce"
    ) do |format|
      format.html { render :layout => true }
    end
  end

  def invite_update_notification(recipient_email, alumnus)
    @alumnus = alumnus
    mail(
      :to => recipient_email,
      :from => "athletics@scoutforce.com",
      :subject => "An Alumnus has just updated their profile on ScoutForce"
    ) do |format|
      format.html { render :layout => true }
    end
  end

  def confirmation_notification(alumnus)
    @alumnus = alumnus
    mail(
      :to => @alumnus.email,
      :from => "athletics@scoutforce.com",
      :subject => "Your profile has been sent to #{@alumnus.program_name}"
    ) do |format|
      format.html { render :layout => true }
    end
  end

end
