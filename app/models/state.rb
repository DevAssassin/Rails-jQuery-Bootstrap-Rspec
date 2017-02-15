class State
  include Mongoid::Document
  add_indexes

  field :name

  referenced_in :country, index: true
end
