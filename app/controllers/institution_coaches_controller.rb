class InstitutionCoachesController < ApplicationController
  respond_to :html

  before_filter :find_institution

  def find_institution
    @institution = Institution.find(params[:institution_id])
  end

  # GET /coaches/new
  # GET /coaches/new.xml
  def new
    @coach = InstitutionCoach.new
    respond_with(@coach)
  end

  # GET /coaches/1/edit
  def edit
    @coach = InstitutionCoach.find(params[:id])
  end

  # POST /coaches
  # POST /coaches.xml
  def create
    @coach = InstitutionCoach.new(params[:institution_coach])
    @coach.institution = @institution
    flash[:notice] = 'Coach was successfully created.' if @coach.save
    respond_with([@institution, @coach], :location => institution_url(@institution))
  end

  # PUT /coaches/1
  # PUT /coaches/1.xml
  def update
    @coach = InstitutionCoach.find(params[:id])
    flash[:notice] = 'Coach was successfully updated.' if @coach.update_attributes(params[:institution_coach])
    respond_with([@institution, @coach], :location => institution_url(@institution))
  end

  # DELETE /coaches/1
  # DELETE /coaches/1.xml
  def destroy
    @coach = InstitutionCoach.find(params[:id])
    @coach.destroy
    respond_with(@institution, :location => institution_url(@institution))
  end
end
