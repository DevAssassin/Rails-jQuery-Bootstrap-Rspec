class PeopleImportsController < ApplicationController
  respond_to :html, :json

  def index
    new
    render 'new'
  end

  def new
    @import = PeopleImport.new
    @programs = current_account.programs
  end

  def edit
    @import = PeopleImport.find(params[:id])
  end

  def create
    @import = PeopleImport.new(params[:people_import])
    @import.account = current_account
    @import.program = current_program || (current_user.find_scoped_programs(params[:people_import][:program_id]) if BSON::ObjectId.legal?(params[:people_import][:program_id]))
    @import.user = current_user

    if @import.save
      respond_with @import, :location => edit_people_import_path(@import)
    else
      respond_with @import, :render => 'index'
    end
  end

  def update
    @import = current_account.people_imports.find(params[:id])
    params[:people_import][:actions].each do |column_id,action|
      @import.actions[column_id.to_i] = action
    end

    if @import.save
      @import.delay(:priority => 2).execute
      respond_with @import, :location => people_path
    else
      respond_with @import, :location => review_people_import_path
    end
  end

end
