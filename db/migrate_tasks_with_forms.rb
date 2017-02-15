tasks_with_forms = Task.where(:form_id.ne => nil)

puts "Found #{tasks_with_forms.size} tasks to be migrated"
tasks_with_forms.each do |task|
  puts "--> migrating task: #{task.id} (with form: #{task.form_id})"

  form = task.form
  form.update_attribute(:eligible_for_standalone, true)

  form_group = FormGroup.standalone_for(form).first
  raise "Ahh, didn't create the standalone form_group for form: #{form.id}" unless form_group
  task.form_group = form_group

  task.assignments.each do |assignment|
    assignment.form = form

    puts "    migrating assignment: #{assignment.id} (with assignee id: #{assignment.assignee_id})"
    if assignment.completed?
      # Old completed forms may not have assignment_id set, so find it the old way
      completed_form = CompletedForm.where(:task_id => task.id, :assignee_id => assignment.assignee_id).first
      raise "ahh, couldn't find completed form for assignment: #{assignment.id}, but it was marked completed" unless completed_form

      puts "    migrating completed form: #{completed_form.id}"
      completed_form.form_group_id = form_group.id
      completed_form.assignment_id = assignment.id
      completed_form.save!(:validate => false) # would fail 'assignment already complete' validation
      assignment.completed_form_id = completed_form.id
    end
    assignment.save!
  end

  task.form = nil
  task.save!
  puts "    w00t, migrated to: {id: #{task.id}, form_id: #{task.form_id}, form_group_id: #{task.form_group_id}}"
end

completed_forms_without_assignment_id = CompletedForm.where(:form_group_id.ne => nil, :assignment_id => nil)

puts "Found #{completed_forms_without_assignment_id.size} completed forms to be migrated"
completed_forms_without_assignment_id.each do |cf|
  puts "--> migrating completed form: #{cf.id} (with task: #{cf.task_id})"
  task = cf.task
  assignment = task.assignments.detect{ |a| a.completed_form_id == cf.id }
  cf.assignment_id = assignment.id
  cf.save!(:validate => false)
  puts "    w00t, added assignment: #{assignment.id}"
end
