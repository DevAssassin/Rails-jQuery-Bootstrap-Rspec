class CompletedFormsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json
  include Canable::Enforcers

  set_tab :forms

  def index
    @completed_forms = scope.completed_forms
  end

  def show
    @completed_form = scoped_completed_forms.find(params[:id])
  end

  def grouped
    @task = current_account.tasks.from_form_group_thread_id(params[:form_group_thread_id]).first
    @completed_forms = CompletedForm.from_form_group_thread_id(params[:form_group_thread_id])
    @reviewed = @completed_forms.all?(&:reviewed?)
    @reviewed_by = @completed_forms.first { |c| c.reviewed_by.present? }.try(:reviewed_by)
  end

  def preview
    @template = current_account.form_template

    if params[:form_id]
      @completed_form = current_account.forms.find(params[:form_id]).completed_forms.find(params[:id])
      render :preview_single, :layout => 'form'

    elsif params[:form_group_thread_id]
      @assignments = Assignment.from_form_group_thread_id(params[:form_group_thread_id])
      render :preview_grouped, :layout => 'form'
    end
  end

  def dynatable
    @completed_forms = scoped_completed_forms

    unless params[:queries].blank? || params[:queries][:search].blank?
      search = Regexp.new(params[:queries][:search], true)
      @completed_forms = @completed_forms.any_of(
        { :name => search },
        { 'form.name' => search },
        { :submitter_name => search }
      )
    end

    unless params[:sorts].blank?
      params[:sorts].each do |attr, asc|
        @completed_forms = @completed_forms.order_by([attr, (asc == "1" ? :asc : :desc)])
      end
    end

    queried_record_count = @completed_forms.count

    @completed_forms = @completed_forms.limit(params[:limit].to_i).offset(params[:offset].to_i)
    @completed_forms = @completed_forms.to_a
    @completed_forms.each do |c|
      c[:form_name] = c.form.name
      c[:form_link] = form_path(c.form_id)
      c[:task_name] = c.task ? c.task.name : ''
      c[:completed_at] = c.created_at.to_formatted_s
      c[:reviewed] = c.reviewed? ? 'Yes' : 'No'
      c[:completed_form_link] = form_completed_form_url(c.form_id, c.id)
    end

    if scope.is_a?(FormGroup)
      @completed_forms = CompletedForm.to_grouped(@completed_forms)
      @completed_forms.each do |c|
        c[:completed_form_link] = grouped_form_group_completed_forms_url(params[:form_group_id], c[:form_group_thread_id])
        c[:task_name] = c[:task].name
        c[:forms] = c[:task].forms.collect(&:name)
        c[:assignee_names] = c[:individual_completed_forms].collect(&:submitter_name)
        c[:completed_at] = c[:individual_completed_forms].sort_by(&:created_at).last.created_at.to_formatted_s
        c[:reviewed] = c[:individual_completed_forms].all?(&:reviewed?) ? 'Yes' : 'No'
      end
    end

    json = {
      :queried_record_count => queried_record_count,
      :records => @completed_forms
    }

    respond_to do |format|
      format.json { render :json => json }
    end
  end

  def update
    if params[:form_group_id]
      @completed_forms = CompletedForm.from_form_group_thread_id(params[:id])
      @completed_forms.each do |c|
        c.update_attribute(:reviewed,params[:reviewed] == '1')
        c.update_attribute(:reviewed_by_id,current_user.id)
      end
      redirect_to grouped_form_group_completed_forms_url(params[:form_group_id], params[:id])
    else
      @completed_form = scope.completed_forms.find(params[:id])
      @completed_form.update_attribute(:reviewed,params[:completed_form][:reviewed] == '1')
      @completed_form.update_attribute(:reviewed_by_id,current_user.id)
      respond_with [@completed_form.form, @completed_form]
    end
  end

  def destroy
    enforce_destroy_permissions(CompletedForm)
    if params[:form_group_id]
      CompletedForm.destroy_all_by_thread_id(params[:id])
    else
      current_scope.completed_forms.find(params[:id]).destroy
    end

    redirect_to params[:form_group_id] ? form_group_completed_forms_path(params[:form_group_id]) : form_completed_forms_path(params[:form_id])
  end

  private

  def enforce_destroy_permissions(resource)
    raise Canable::Transgression unless current_user.can_destroy?(resource)
  end

  def scope
    @scope ||= case
    when params[:form_id]
      current_account.forms.find(params[:form_id])
    when params[:form_group_id]
      current_account.form_groups.find(params[:form_group_id])
    else
      current_account
    end
  end

  def scoped_completed_forms
    criteria = {}
    criteria[:program_id] = current_program.id if current_program
    scope.completed_forms.where(criteria)
  end

end
