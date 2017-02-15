class FeedbackMailer < ActionMailer::Base
  layout "email"

  def feedback(feedback)
    @feedback = feedback
    mail(
      :to => "support@scoutforce.com",
      :from => "athletics@scoutforce.com",
      :subject => "[Feedback] Someone has filled out the feedback form."
    ) do |format|
      format.html { render :layout => true }
    end
  end

end
