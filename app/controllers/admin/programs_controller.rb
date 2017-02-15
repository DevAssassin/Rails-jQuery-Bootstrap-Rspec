class Admin::ProgramsController < AdminController
  respond_to :html

  # GET /admin_programs/1
  # GET /admin_programs/1.xml
  def show
    @program = Program.find(params[:id])

    respond_with(:admin, current_account, @program)
  end

  # GET /admin_programs/new
  # GET /admin_programs/new.xml
  def new
    @program = Program.new

    respond_with(:admin, current_account, @program)
  end

  # GET /admin_programs/1/edit
  def edit
    @program = Program.find(params[:id])
  end

  # POST /admin_programs
  # POST /admin_programs.xml
  def create
    @program = Program.new(params[:program])
    @program.sport_class_name = params[:program][:sport_class_name]
    @program.account = current_account

    flash[:notice] = 'Program was successfully created.' if @program.save
    respond_with(:admin, current_account, @program)
  end

  # PUT /admin_programs/1
  # PUT /admin_programs/1.xml
  def update
    @program = Program.find(params[:id])
    @program.sport_class_name = params[:program][:sport_class_name]

    flash[:notice] = 'Program was successfully updated.' if @program.update_attributes(params[:program])
    respond_with(:admin, current_account, @program)
  end

  # DELETE /admin_programs/1
  # DELETE /admin_programs/1.xml
  def destroy
    @program = Program.find(params[:id])
    @program.destroy
    respond_with(:admin, current_account, @program, :location => admin_account_path(current_account))
  end
end
