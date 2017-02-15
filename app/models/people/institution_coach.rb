class InstitutionCoach < Person
  field :office_phone, :type => MongoTypes::PhoneNumber
  field :sport

  referenced_in :institution, index: true
end
