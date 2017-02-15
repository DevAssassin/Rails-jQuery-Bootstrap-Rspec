Fabricator(:assignment) do
  assignee { |a| Fabricate(:person_with_email) }
end
