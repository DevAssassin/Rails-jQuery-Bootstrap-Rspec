Fabricator(:basic_task, :class_name => :task) do
  name "Do something"
  user!
  account!
end

Fabricator(:task, :from => :basic_task) do
  assignees { |t| [ Fabricate(:person) ] }
end

Fabricator(:task_with_deadline, :from => :task) do
  due_at 1.hour.from_now
end

Fabricator(:task_with_form_group, :from => :basic_task) do
  form_group! { |t| Fabricate(:form_group, :account => t.account) }
  after_create { |t|
    if t.assignments.empty?
      t.form_group.forms.each do |form|
        t.assignments.concat([ Fabricate.build(:assignment, :form => form) ])
      end
    end
  }
  due_at 1.hour.from_now
end

Fabricator(:task_with_form_group_and_assignees, :from => :task_with_form_group) do
  assignments do |t|
    t.form_group.forms.map do |form|
      Fabricate.build(:assignment, :form => form)
    end
  end
end

Fabricator(:task_with_threads, :from => :basic_task) do
  form_group! { |t| Fabricate(:form_group, :account => t.account) }
  after_create { |t|
    t.assignments.concat([
      a1 = Fabricate.build(:assignment, :form => t.form_group.forms.first),
      a2 = Fabricate.build(:assignment, :form => t.form_group.forms.first),
      a3 = Fabricate.build(:assignment, :form => t.form_group.forms.second, :dependent_assignment_id => a1.id),
      a4 = Fabricate.build(:assignment, :form => t.form_group.forms.second, :dependent_assignment_id => a2.id, :assignee => a3.assignee)
    ])
  }
end
