class InteractionMailer < ActionMailer::Base
  include Cells::Rails::ActionController
  layout "raw_email"
  helper :application

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.interaction_mailer.recruit_email.subject
  #
  def recruit_email(recipient, interaction, email)
    @interaction = interaction

    full_body = email.templated_body_for(recipient, :raw => true)
    reply_to = "#{email.from.email_from} <#{email.from.email}>"
    from = "#{email.from.email_from} <athletics@scoutforce.com>"

    mail(
      :to => recipient.email,
      :from => from,
      :reply_to => reply_to,
      :cc => email.cc,
      :bcc => email.bcc,
      :subject => email.subject,
      :'X-Mailgun-Variables' => %({"recipient_id" : "#{recipient.id}", "email_id" : "#{email.id}", "interaction_id" : "#{interaction.id}" })
    ) do |format|
      format.text
      format.html do
        render :text => full_body, :layout => true
      end
    end
  end

  def copy_sender(recipient, email)
    full_body = email.templated_body_for(recipient, :raw => true)
    reply_to = "#{email.from.email_from} <#{email.from.email}>"
    from = "#{email.from.email_from} <athletics@scoutforce.com>"

    mail(
      :to => recipient.email,
      :from => from,
      :reply_to => reply_to,
      :cc => email.cc,
      :bcc => email.bcc,
      :subject => email.subject
    ) do |format|
      format.html do
        render :text => full_body, :layout => true
      end
    end
  end
end
