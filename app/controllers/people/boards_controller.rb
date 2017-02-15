class People::BoardsController < ApplicationController
  respond_to :html, :json, :js

  def unassigned
    @person = current_scope.people.find(params[:person_id])
    @boards = current_scope.recruit_boards - @person.recruit_boards.order_by([[:name, :asc]])
    respond_with @boards.map { |w| {:id => w.id, :name => w.name} }
  end

  def add
    @board = current_scope.recruit_boards.find(params[:board])
    @board.push_recruit(current_scope.people.find(params[:person_id]))
    @board.save
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  def remove
    @board = current_scope.recruit_boards.find(params[:id])
    @board.remove_recruit(current_scope.people.find(params[:person_id]))
    @board.save
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end


end
