module HotDate
  extend ActiveSupport::Concern

  module ClassMethods
    def hot_date(date_name)
      define_method("#{date_name}=") do |new_date|
        date = Kronic.parse(new_date)
        date = Chronic.parse(new_date).try(:to_date) unless date

        super(date)
      end
    end

    def hot_datetime(datetime_name)
      define_method("#{datetime_name}=") do |datetime|
        new_datetime = Chronic.parse(datetime)

        super(new_datetime || datetime)
      end
    end
  end # ClassMethods
end
