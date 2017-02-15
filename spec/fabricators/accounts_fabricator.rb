Fabricator(:account) do
  name "Test Account"
  compliance true
end

Fabricator(:account_with_sms, from: :account) do
  allow_sms true
end

Fabricator(:account_with_recruit_sms, from: :account_with_sms) do
  can_sms_recruits true
end

Fabricator(:basic_account, from: :account) do
  compliance false
  allow_phonecalls false
  allow_sms false
  rules_engine false
end

Fabricator(:account_with_program, :from => :account) do
  programs(:count => 1)
end

Fabricator(:full_account, from: :account) do
  allow_phonecalls true
  allow_sms true
  can_sms_recruits true
  rules_engine true
end
