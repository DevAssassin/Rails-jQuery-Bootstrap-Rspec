class Sport::GolfEvent
  include Mongoid::Document

  embedded_in :recruit

  field :kind
  field :score
  field :place
  field :date

end
