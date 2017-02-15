class InteractionObserver < Mongoid::Observer
  def after_save(interaction)
    account = interaction.account
    account.update_attribute(:activity_at,Time.now) if account
  end
end
