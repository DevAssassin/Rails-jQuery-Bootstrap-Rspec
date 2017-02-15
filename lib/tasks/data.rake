namespace :data do
  desc "Rename coach fields"
  task :rename_coach_fields => :environment do
    fields = {}
    ["trainer","instructor","teacher"].each do |coach_type|
      fields.merge!({
        "high_school_#{coach_type}_name" => "high_school_coach_name",
        "high_school_#{coach_type}_phone" => "high_school_coach_phone",
        "high_school_#{coach_type}_email" => "high_school_coach_email",
        "club_#{coach_type}_name" => "club_coach_name",
        "club_#{coach_type}_phone" => "club_coach_phone",
        "club_#{coach_type}_email" => "club_coach_email",
        "other_teams_#{coach_type}_info" => "other_teams_coach_info"
      })
    end
    fields.each { |old,new| Person.collection.update({}, {'$rename' => {old => new}}, :multi => true) }
  end

  desc "Migrate email events"
  task :migrate_email_events => :environment do
    EmailEvent::Open.all.each do |e|
      event = EmailEvent.create({
        :event => 'open',
        :timestamp => e.event_time.to_i,
        :interaction => e.interaction
      })
      e.destroy
    end
  end

  desc "Migrate recruit status"
  task :migrate_recruit_status => :environment do
    Recruit.all.each { |r| r.update_attribute(:status,r.status.presence || 'New') }
  end
end
