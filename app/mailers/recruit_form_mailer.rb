class RecruitFormMailer < ActionMailer::Base
  layout "email"

  def online_create_notification(recipient_email, recruit)
    @recruit = recruit
    attachments.inline['recruit.jpg'] = File.read(@recruit.photo.url(:thumb)) if @recruit.photo.url
    mail(
      :to => recipient_email,
      :from => "athletics@scoutforce.com",
      :subject => "A Recruit has just created a profile on ScoutForce"
    ) do |format|
      format.html { render :layout => true }
    end
  end

  def invite_update_notification(recipient_email, recruit)
    @recruit = recruit
    mail(
      :to => recipient_email,
      :from => "athletics@scoutforce.com",
      :subject => "A Recruit has just updated their profile on ScoutForce"
    ) do |format|
      format.html { render :layout => true }
    end
  end

  def confirmation_notification(recruit)
    @recruit = recruit

    mail(
      :to => @recruit.email,
      :from => "athletics@scoutforce.com",
      :subject => "Your profile has been sent to #{recruit.program.try(:name)}"
    ) do |format|
      format.html { render :layout => true }
    end
  end
end
