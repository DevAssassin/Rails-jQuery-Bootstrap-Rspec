class SendgridController < ActionController::Metal

  def callback
    self.status = 200
    self.response_body = ""
    if params[:interaction_id]
      return unless interaction = Interaction.find(params[:interaction_id])
      event = EmailEvent.new(params)
      event.interaction = interaction
      interaction.touch if event.save
    end
    return unless params[:_json]
    params[:_json].each do |p|
      return unless p[:interaction_id]
      return unless interaction = Interaction.find(p[:interaction_id])
      event = EmailEvent.new(p)
      event.interaction = interaction
      interaction.touch if event.save
    end
  end
end