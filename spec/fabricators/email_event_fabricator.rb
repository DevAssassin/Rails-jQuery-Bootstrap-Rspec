Fabricator(:email_event) do
  event_time { Time.now }
end

Fabricator(:email_event_open, :class_name => EmailEvent::Open, :from => :email_event) do
end

