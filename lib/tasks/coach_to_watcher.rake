namespace :recruits do
  desc "Make coaches become watchers in recruits"
  task :coach_to_watcher => :environment do
    Recruit.all.each do |r|
      r.watcher_ids.concat(r['coach_ids'].to_a).uniq!
      r.unset(:coach_ids)
      r.save!(validate: false)
    end
  end
end
