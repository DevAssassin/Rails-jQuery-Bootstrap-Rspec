class Sport::GymnasticsEvent
  include Mongoid::Document

  embedded_in :recruit

  field :kind
  field :score
  field :date

  Kinds = ["Vault","Bars","Beam","Floor","All Around"]

end
