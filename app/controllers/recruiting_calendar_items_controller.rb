class RecruitingCalendarItemsController < ApplicationController
 respond_to :html
  set_tab :rules

  before_filter :find_program

  def find_program
    @program = current_user.find_scoped_programs(params[:program_id])
  end

  def index
    @items = @program.recruiting_calendar_items
    respond_with(@items)
  end

  def new
    @item = RecruitingCalendarItem.new
    respond_with(@item)
  end

  def edit
    @item = RecruitingCalendarItem.find(params[:id])
  end

  def create
    @item = RecruitingCalendarItem.new(params[:recruiting_calendar_item])
    @item.program = @program
    flash[:notice] = 'Recruiting calendar item was successfully created.' if @item.save
    respond_with(@item, :location => program_recruiting_calendar_items_path(@program))
  end

  def update
    @item = RecruitingCalendarItem.find(params[:id])
    flash[:notice] = 'Recruiting calendar item was successfully updated.' if @item.update_attributes(params[:recruiting_calendar_item])
    respond_with(@item, :location => program_recruiting_calendar_items_path(@item.program))
  end

  def destroy
    @item = RecruitingCalendarItem.find(params[:id])
    @program = @item.program
    @item.destroy
    respond_with(@item, :location => program_recruiting_calendar_items_path(@program))
  end
end
