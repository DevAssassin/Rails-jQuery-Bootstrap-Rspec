class Counselor < Person
  field :office_phone, :type => MongoTypes::PhoneNumber

  referenced_in :institution, index: true
end
