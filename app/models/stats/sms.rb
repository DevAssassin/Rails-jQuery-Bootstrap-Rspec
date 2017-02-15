class Stats::Sms < BasicActiveModel

  def self.log(interaction)
    Mongoid.database.collection("sms_stats").save({
      interaction_id: interaction.id,
      to: interaction.phone_number,
      account_id: interaction.account.try(:id),
      program_id: interaction.program.try(:id),
      user_id: interaction.user.try(:id),
      timestamp: Time.now
    })
  end

  def self.accounts
    Mongoid.database.collection("sms_stats").group(
      :key => :account_id,
      :cond => { :account_id => { "$ne" => nil } },
      :reduce => "function(doc,out) { out.count++ }",
      :initial => { :count => 0 }
    )
  end

  def self.programs(account)
    Mongoid.database.collection("sms_stats").group(
      :key => :program_id,
      :cond => { :program_id => { "$ne" => nil }, :account_id => account.id },
      :reduce => "function(doc,out) { out.count += 1; }",
      :initial => { :count => 0 }
    )
  end

  def self.user(user)
    Mongoid.database.collection("sms_stats").find({user_id: user.id}).count
  end

end
