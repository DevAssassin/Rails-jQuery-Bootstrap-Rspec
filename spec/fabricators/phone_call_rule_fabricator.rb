Fabricator(:phone_call_rule) do
  school_class "Freshman"
  transfer_type ""
  start_time "2011-01-01 00:00:00 EST"
  end_time "2011-03-01 00:00:00 EST"
  calls_allowed 1
  time_period "month"
  message "RULE_FAIL_MESSAGE"
end

Fabricator(:january_phone_call_rule, from: :phone_call_rule) do
  start_time "2011-01-01 00:00:00 EST"
  end_time "2011-02-01 00:00:00 EST"
end

Fabricator(:february_phone_call_rule, from: :phone_call_rule) do
  start_time "2011-02-01 00:00:00 EST"
  end_time "2011-03-01 00:00:00 EST"
end

Fabricator(:freshman_phone_call_rule, from: :phone_call_rule) do
  school_class "Freshman"
end

Fabricator(:sophomore_phone_call_rule, from: :phone_call_rule) do
  school_class "Sophomore"
end

Fabricator(:junior_phone_call_rule, from: :phone_call_rule) do
  school_class "Junior"
end

Fabricator(:senior_phone_call_rule, from: :phone_call_rule) do
  school_class "Senior"
end

Fabricator(:unlimited_phone_call_rule, from: :phone_call_rule) do
  calls_allowed -1
end

Fabricator(:transfer_phone_call_rule, from: :phone_call_rule) do
  transfer_type 'Two Year'
  school_class ''
end

Fabricator(:two_year_phone_call_rule, from: :transfer_phone_call_rule) do

end

Fabricator(:four_year_phone_call_rule, from: :transfer_phone_call_rule) do
  transfer_type 'Four Year'
end

Fabricator(:prep_phone_call_rule, from: :transfer_phone_call_rule) do
  transfer_type 'Prep'
end
