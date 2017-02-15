# Provides functionality for turning a hash describing some relative datetime
# into an absolute datetime. For example:
#
#     class MyClass
#       include Scheduler
#     end
#
#     MyClass.date_from_hash(:amount => "1", :unit => "day")
#     #=> the equivalent of 1.day.from_now
#
#     MyClass.date_from_hash(:amount => "1", :unit => "month", :relative_to => 2.days.from_now, :relative_direction => "before")
#     #=> the equivalent of 1.month.ago(2.days.from_now)
#
# You can also give instance attributes of your class the power of scheduling:
#
#     class MyClass
#       include Scheduler
#       schedulable_attributes :send_time
#     end
#
#     thing = MyClass.new
#     thing:send_time = {:amount => "1", :unit => "year"}
#     thing.schedule
#     thing.send_time #=> the equivalent of 1.year.from_now
#
module Scheduler
  BEFORE = [:ago, :before]
  AFTER = [:from, :from_now, :since, :after]

  def self.included(base)
    base.extend ClassMethods
    base.send(:cattr_accessor, :schedule_attributes)
  end

  def schedule!
    self.class.schedule_attributes.each do |attr|
      if attr.is_a?(Enumerable)
        attr.to_a.each do |before, after|
          self.send("#{after}=".to_sym, self.class.date_from_hash(self.send(before)))
        end
      else
        self.send("#{attr}=".to_sym, self.class.date_from_hash(self.send(attr)))
      end
    end
    return self
  end

  module ClassMethods
    def schedulable_attributes(*attribute_names)
      self.schedule_attributes = attribute_names
      attribute_names.each do |attr|
        # Defined as :schedule_send => :send_time
        # where `schedule_send` would be the value that has the relative hash
        # and `send_time` receives the absolute datetime
        if attr.is_a?(Enumerable)
          attr.to_a.each do |before, after|
            attr_accessor before unless self.new.respond_to?(before)
            attr_accessor after unless self.new.respond_to?(after)
          end

        # Defined simply as :send_time
        # where it originally has the relative hash and overwrites itself
        # with the absolute datetime
        else
          attr_accessor attr unless self.new.respond_to?(attr)
        end
      end
    end

    def date_from_hash(hash)
      if hash.is_a?(Hash)
        hash = hash.with_indifferent_access
      end

      relative_direction = hash[:relative_direction] ? hash[:relative_direction].to_sym : :from
      amount             = BEFORE.include?(relative_direction) ? -hash[:amount].to_i : hash[:amount].to_i
      unit               = hash[:unit].to_s.pluralize.to_sym
      relative_to        = hash[:relative_to].blank? ? Time.zone.now : hash[:relative_to].to_datetime

      return relative_to.advance(unit => amount)
    end
  end
end
