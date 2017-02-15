class Sport::TrackAndFieldEvent
  include Mongoid::Document

  embedded_in :recruit

  field :name
  field :result
  field :location
  field :date

end
