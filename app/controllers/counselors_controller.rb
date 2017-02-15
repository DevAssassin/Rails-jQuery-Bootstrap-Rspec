class CounselorsController < ApplicationController
  respond_to :html

  before_filter :find_institution

  def find_institution
    @institution = Institution.find(params[:institution_id])
  end

  # GET /counselors/new
  # GET /counselors/new.xml
  def new
    @counselor = Counselor.new
    respond_with(@counselor)
  end

  # GET /counselors/1/edit
  def edit
    @counselor = Counselor.find(params[:id])
  end

  # POST /counselors
  # POST /counselors.xml
  def create
    @counselor = Counselor.new(params[:counselor])
    @counselor.institution = @institution
    flash[:notice] = 'Counselor was successfully created.' if @counselor.save
    respond_with([@institution, @counselor], :location => institution_url(@institution))
  end

  # PUT /counselors/1
  # PUT /counselors/1.xml
  def update
    @counselor = Counselor.find(params[:id])
    flash[:notice] = 'Counselor was successfully updated.' if @counselor.update_attributes(params[:counselor])
    respond_with([@institution, @counselor], :location => institution_url(@institution))
  end

  # DELETE /counselors/1
  # DELETE /counselors/1.xml
  def destroy
    @counselor = Counselor.find(params[:id])
    @counselor.destroy
    respond_with(@institution, :location => institution_url(@institution))
  end
end
