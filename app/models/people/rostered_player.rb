class RosteredPlayer < Person

  after_update :deliver_invite_update_notifications, :if => :updated_by_rostered_player
  after_update :add_profile_update_interaction,      :if => :updated_by_rostered_player

  field :student_id
  field :family
  field :hobbies
  field :graduation_year
  field :eligibility_status
  field :term_first_enrolled
  field :number_of_years_received_aid
  field :number_of_years_eligibility_used
  field :recruited
  field :period_of_award
  field :athtletic_grant_amount
  field :other_countable_aid
  field :total_countable_aid
  field :exempt, :type => Boolean
  field :full_grant_amount
  field :initially_enrolled_at_school, :type => Boolean
  field :overall_countable, :type => Boolean
  field :equivalent_award_amount
  field :change_in_status_reason
  field :date_of_change_in_status, :type => Date
  hot_date :date_of_change_in_status
  field :revised_equivalent_award

  attr_accessor :created_by_rostered_player, :updated_by_rostered_player

  def self.import_fields
    super - %w{alumnus alumnus_sport alumnus_years_played alumnus_grad_year alumnus_post_grad_education parent donor donor_notes latest_donation_time latest_donation_amount exempt initially_enrolled_at_school overall_countable}
  end

end
