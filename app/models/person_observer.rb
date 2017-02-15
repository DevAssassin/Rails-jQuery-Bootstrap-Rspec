class PersonObserver < Mongoid::Observer
  def after_save(person)
    account = person.account
    if account
      account.activity_at = Time.now
      account.save
    end
  end
end
