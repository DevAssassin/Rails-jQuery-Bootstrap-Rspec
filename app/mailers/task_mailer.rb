class TaskMailer < ActionMailer::Base
  include Cells::Rails::ActionController
  layout "email"
  helper :application

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.interaction_mailer.recruit_email.subject
  #
  def task_assigned(recipient, assignment, task)
    @task = task
    @root_url = root_url
    if @task.form || @task.form_group
      @form = @task.form ? @task.form : assignment.form
      @url = form_complete_url(@form, :auth_token => recipient.authentication_token, :task_id => @task.id)
    end

    mail(
      :to => recipient.email,
      :from => "athletics@scoutforce.com",
      :subject => "You have been assigned a task on ScoutForce"
    ) do |format|
      format.html { render :layout => true }
    end
  end

  def form_group_assignment_completed(recipient, assignment, completed_assignment, task)
    @task = task
    @completed_assignment = completed_assignment
    @root_url = root_url
    @form = assignment.form
    @url = form_complete_url(assignment.form, :auth_token => recipient.authentication_token, :task_id => @task.id, :assignment_id => assignment.id)

    mail(
      :to => recipient.email,
      :from => "athletics@scoutforce.com",
      :subject => "#{completed_assignment.assignee.name} has completed their task on ScoutForce",
    ) do |format|
      format.html { render :layout => true }
    end
  end
end

