class Interactions::Donation < Interaction
  field :amount, type: BigDecimal

  after_save :update_latest_donation, :make_donor

  def amount=(amt)
    case amt
    when String
      super(amt.gsub(/[^.0-9]/,''))
    else
      super(amt)
    end
  end

  def self.export_header
    super + ["Amount"]
  end

  def self.export_fields
    super + [:amount]
  end

  private
  def update_latest_donation
    if person
      latest = person.latest_donation_time || DateTime.civil

      if interaction_time > latest
        person.latest_donation_time = interaction_time
        person.latest_donation_amount = amount
        person.save
      end
    end
  end

  def make_donor
    if person
      person.donor = true
      person.save
    end
  end
end
