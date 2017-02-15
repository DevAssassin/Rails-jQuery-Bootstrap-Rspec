class InstitutionsController < ApplicationController
  respond_to :html, :json
  #include ActionView::Helpers::UrlHelper
  skip_before_filter :authenticate_user!, :set_user_state, :only => [:search,:create]

  set_tab :institutions

  Types = ["High School","College","Club"]

  # GET /institutions
  # GET /institutions.xml
  def index
    @institutions = Institution.all
    respond_with(@institutions)
  end

  def dynatable
    @institutions = Institution.all
    unless params[:queries].blank?
      unless params[:queries][:search].blank?
        search = Regexp.new(Regexp.quote(params[:queries][:search]), true)
        @institutions = @institutions.where(:name => search)
      end
      unless params[:queries][:user_filter].blank?
        @institutions = @institutions.where(:user_ids => params[:queries][:user_filter])
      end
    end

    unless params[:sorts].blank?
      params[:sorts].each do |attr, asc|
        @institutions = @institutions.order_by([attr, (asc == "1" ? :asc : :desc)])
      end
    end

    queried_record_count = @institutions.count
    @institutions = @institutions.limit(params[:limit].to_i).offset(params[:offset].to_i)

    # TODO: Move this to decorator object
    # must do `.to_a` to get custom attributes to stick
    @institutions = @institutions.to_a
    @institutions.each do |inst|
      inst[:type_name] = inst.type_name
      inst[:show_link] = institution_path(inst)
      inst[:city] = inst.address.city if inst.address
      inst[:state] = inst.address.state if inst.address
      inst[:recruits_count] = inst.recruits_for_program(current_program).count
    end

    json = {
      :queried_record_count => queried_record_count,
      :records => @institutions
    }

    respond_to do |format|
      format.json { render :json => json }
    end
  end

  # GET /institutions/1
  # GET /institutions/1.xml
  def show
    @institution = Institution.find(params[:id])
    respond_with(@institution)
  end

  # GET /institutions/new
  # GET /institutions/new.xml
  def new
    @institution = School.new
    respond_with(@institution)
  end

  def new_club
    @institution = Club.new
    respond_with(@institution)
  end

  def new_college
    @institution = College.new
    respond_with(@institution)
  end

  # GET /institutions/1/edit
  def edit
    @institution = Institution.find(params[:id])
  end

  # POST /institutions
  # POST /institutions.xml
  def create
    @institution = create_institution(params[:type],params[:institution])
    flash[:notice] = 'Institution was successfully created.' if @institution.save
    respond_with(@institution, :location => institution_url(@institution))
  end

  # PUT /institutions/1
  # PUT /institutions/1.xml
  def update
    @institution = Institution.find(params[:id])
    flash[:notice] = 'Institution was successfully updated.' if @institution.update_attributes(params[:institution])
    respond_with(@institution, :location => institution_url(@institution))
  end

  def update_coaches
    @institution = Institution.find(params[:id])
    flash[:notice] = 'Institution was successfully updated.' if @institution.set_coach_ids_for_program(params[:coach_ids], current_program)
    respond_with(@institution, :location => institution_url(@institution))
  end

  # DELETE /institutions/1
  # DELETE /institutions/1.xml
  def destroy
    @institution = Institution.find(params[:id])
    @institution.destroy
    respond_with(@institution)
  end

  def search
    case params[:type]
    when 'college'
      @institutions = Institution.search(params[:term]).where("_type" => "College").limit(100)
    when 'club'
      @institutions = Institution.search(params[:term]).where("_type" => "Club").limit(100)
    else
      @institutions = Institution.search(params[:term]).where("_type" => "School").limit(100)
    end

    json = @institutions.map do |i|
      {
        :id => i.id,
        :label => i.name.titleize,
        :value => i.name,
        :city => i.address.try(:city).try(:titleize),
        :state => i.address.try(:state)
      }

    end

    respond_with(json)
  end

  private
  def create_institution(kind, *args)
    case kind
    when 'club'
      Club.new(*args)
    when 'college'
      College.new(*args)
    else
      School.new(*args)
    end
  end
end
