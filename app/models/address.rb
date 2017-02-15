class Address
  include Mongoid::Document
  add_indexes

  field :street
  field :city
  field :state
  field :country
  field :post_code

  embedded_in :addressable, :inverse_of => :address

  def self.import_fields
    self.fields.keys - %w{_id _type}
  end
end
