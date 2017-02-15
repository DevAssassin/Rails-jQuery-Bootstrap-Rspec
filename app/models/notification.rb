class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, :type => String
  field :active, :type => Boolean
  field :dismissed_user_ids, :type => Array, :default => []

  named_scope :active, where(:active => true)
  named_scope :recent_first, order_by(:updated_at.desc)
  named_scope :without_dismissed_user, lambda {|u| excludes(dismissed_user_ids: u.id)}

  def self.for_user(user)
    active.recent_first.without_dismissed_user(user)
  end

  def dismiss!(user)
    add_to_set(:dismissed_user_ids, user.id)
  end

  def dismissed?(user)
    dismissed_user_ids.include?(user.id)
  end
end
