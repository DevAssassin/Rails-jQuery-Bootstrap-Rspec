class People::TagsController < ApplicationController
  respond_to :html, :json, :js

  def index
    respond_with @tags = Person.tags_by_scope(current_scope)
  end

  def unapplied
    @person = current_scope.people.find(params[:person_id])
    respond_with @tags = @person.unapplied_tags_by_scope(current_scope)
  end

  def destroy
    Person.delete_tags(current_scope, params[:id])
    redirect_to typed_people_path(session[:type])
  end

  def update
    Person.rename_tag(current_scope, params[:id], params[:new_tag_name])

    redirect_to typed_people_path(session[:type])
  end

  def add
    @person = current_scope.people.find(params[:person_id])
    @person.add_tag(current_scope,params[:tag])
    @person.save
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  def remove
    @person = current_scope.people.find(params[:person_id])
    @person.remove_tag(current_scope,params[:id])
    @person.save
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
end
