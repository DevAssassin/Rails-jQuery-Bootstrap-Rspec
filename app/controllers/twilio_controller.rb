class TwilioController < ApplicationController
  skip_before_filter :verify_authenticity_token, :authenticate_user!, :set_user_state

  def connect
    interaction = Interaction.find(params[:interaction_id])

    verb = Twilio::Verb.new do |v|
      v.say "Connecting you to the recruit"
      v.dial interaction.phone_number, :callerId => interaction.caller_id
    end

    render :text => verb.response, :content_type => "text/xml"
  end

  def complete
    interaction = Interaction.find(params[:interaction_id])

    duration = params["CallDuration"]

    interaction.duration = duration
    interaction.status = "Completed"
    interaction.countable = true
    interaction.force = true

    interaction.save!
    interaction.execute

    render :nothing => true
  end

  def sms_callback
    interaction = Interaction.find(params[:interaction_id])

    interaction.status = params["SmsStatus"]
    interaction.update_log
    interaction.save(:validate => false)

    render :nothing => true
  end
end
