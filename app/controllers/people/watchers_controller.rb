class People::WatchersController < ApplicationController
  respond_to :html, :json, :js

  def unassigned
    @person = current_scope.people.find(params[:person_id])
    @watchers = current_scope.users - @person.watchers
    respond_with @watchers.map { |w| {:id => w.id, :name => w.name} }
  end

  def add
    @person = current_scope.people.find(params[:person_id])
    watcher = current_scope.users.find params[:watcher]
    @person.add_watchers([watcher])
    @person.save
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  def remove
    @person = current_scope.people.find(params[:person_id])
    @person.watcher_ids -= [BSON::ObjectId.from_string(params[:id])]
    @person.save
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

end
