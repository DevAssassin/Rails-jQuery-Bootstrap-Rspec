class TournamentsController < ApplicationController
  respond_to :html, :json

  set_tab :tournaments

  def index
    @tournaments = current_program.tournaments.current.order_by([[:begin_date,:asc]])
    set_tab :upcoming, :subnav
    respond_with(@tournaments)
  end

  def show
    @tournament = current_scope.tournaments.find(params[:id])
    respond_with(@tournament)
  end

  def past
    @tournaments = current_scope.tournaments.past.order_by([[:begin_date,:desc]])
    set_tab :past, :subnav
    respond_with @tournaments do |format|
      format.html { render 'index' }
    end
  end

  def new
    @tournament = Tournament.new
    respond_with(@tournament)
  end

  def create
    @tournament = current_scope.tournaments.build(params[:tournament])
    flash[:notice] = 'Event was successfully created.' if @tournament.save
    respond_with(@tournament)
  end

  def edit
    @tournament = Tournament.find(params[:id])
  end

  def update
    @tournament = Tournament.find(params[:id])
    flash[:notice] = 'Event was successfully updated.' if @tournament.update_attributes(params[:tournament])
    respond_with(@tournament)
  end

  def destroy
    @tournament = current_scope.tournaments.find(params[:id])
    flash[:notice] = 'Event was successfully deleted.' if @tournament.destroy
    redirect_to tournaments_url
  end

end
