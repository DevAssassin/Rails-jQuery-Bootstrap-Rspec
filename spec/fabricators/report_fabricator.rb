Fabricator(:report) do
  name "TestReport"
  start_date "2011-03-1"
  end_date "2011-03-31"
end

Fabricator(:comment_report, :from => :report) do
  interaction_type "Comment"
end

Fabricator(:creation_report, :from => :report) do
  interaction_type "Creation"
end
