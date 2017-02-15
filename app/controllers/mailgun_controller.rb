class MailgunController < ActionController::Metal

  def callback
    self.status = 200
    self.response_body = ""

    if params[:interaction_id]
      return unless interaction = Interaction.find(params[:interaction_id])
      event = EmailEvent.new(params)
      event.interaction = interaction
      if event.save
        interaction.touch
      end
    end
  end
end