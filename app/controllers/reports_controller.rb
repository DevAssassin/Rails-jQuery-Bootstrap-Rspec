class ReportsController < ApplicationController
  respond_to :html, :csv, :pdf

  set_tab :reports

  INTERACTION_TYPES = [
    ['Alert', 'Alert'],
    ['Comment', 'Comment'],
    ['Contact & Eval', 'Contact'],
    ['Creation', 'Creation'],
    ['Deletion', 'Deletion'],
    ['Donation', 'Donation'],
    ['Email', 'Email'],
    ['Letter', 'Letter'],
    ['Phone Call', 'PhoneCall'],
    ['Rating', 'Rating'],
    ['Restoration', 'Restoration'],
    ['SMS', 'Sms'],
    ['Update', 'ProfileUpdate'],
    ['Visit', 'Visit'],
  ]

  def index
    @reports = current_scope.reports.all.desc("updated_at")
    @reports = @reports.where(:user_id => params[:user_filter]) unless params[:user_filter].blank?

    respond_with(@reports)
  end

  def show
    @report = current_scope.reports.find(params[:id])
    respond_with(@report)
  end

  def new
    @report = Report.new
    respond_with(@report)
  end

  def edit
    @report = current_scope.reports.find(params[:id])
  end

  def create
    @report = current_scope.reports.build(params[:report])
    @report.user = current_user
    flash[:notice] = 'Report was successfully created.' if @report.save
    respond_with(@report, :location => reports_url)
  end

  def update
    @report = current_scope.reports.find(params[:id])
    flash[:notice] = 'Report was successfully updated.' if @report.update_attributes(params[:report])
    respond_with(@report, :location => reports_url)
  end

  def destroy
    @report = current_scope.reports.find(params[:id])
    @report.destroy
    redirect_to reports_url
  end
end
