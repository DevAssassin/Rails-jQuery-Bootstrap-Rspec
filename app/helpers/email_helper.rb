module EmailHelper
  def email_form(email, &block)
    if email.new_record?
      semantic_form_for(email, :url => emails_url, :html => {:multipart => true}, &block)
    else
      # TODO: Figure out where EmailController#show is being used and stop it from overriding email_path,
      # which should be from EmailsController#show
      semantic_form_for(email, :url => "/emails/#{email.id}", :method => :put, :html => {:multipart => true}, &block)
    end
  end

  def recipients_without_email_message(recipients)
    if recipients.count <= 11
      out = "The following recipients have no email address in their profile, and so cannot receive emails:"
      out << "<br />"
      out << recipients.collect(&:name).join(', ')
    else
      out = "More than 10 of your recipients have no email address in their profile, and so cannot receive emails."
    end
  end

  def recipients_links(email)
    [].tap do |a|
      email.recipients.each do |recipient|
        a << link_to(recipient.name, person_path(recipient))
      end
    end.join(', ').html_safe
  end

  def hide_schedule?(email)
    email.new_record? || email.schedule.nil?
  end
end
