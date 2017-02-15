class Schedule
  include Mongoid::Document
  add_indexes

  field :amount
  field :unit
  field :relative_to, :type => DateTime
  field :relative_direction

  embedded_in :email
end
