class Admin::EmailTemplatesController < AdminController
  respond_to :html

  # GET /admin_email_templates
  # GET /admin_email_templates.xml
  def index
    @email_templates = current_scope.email_templates.all

    respond_with(@email_templates)
  end

  # GET /admin_email_templates/1
  # GET /admin_email_templates/1.xml
  # def show
  #   @email_template = EmailTemplate.find(params[:id])
  #   respond_with(@email_template)
  # end

  # GET /admin_email_templates/new
  # GET /admin_email_templates/new.xml
  def new
    @email_template = EmailTemplate.new
    15.times { @email_template.assets.build }

    respond_with(@email_template)
  end

  # GET /admin_email_templates/1/edit
  def edit
    @email_template = EmailTemplate.find(params[:id])
    (15 - @email_template.assets.count).times { @email_template.assets.build }
  end

  # POST /admin_email_templates
  # POST /admin_email_templates.xml
  def create
    @email_template = EmailTemplate.new(params[:email_template])
    if current_program
      @email_template.program = current_program
    else
      @email_template.account = current_account
    end

    if @email_template.save
      flash[:notice] = 'EmailTemplate was successfully created.'
      @email_template.assets.each(&:save)
      redirect_to :action => 'index', :account_id => current_account, :program_id => current_program
    else
      (15 - @email_template.assets.count).times { @email_template.assets.build }
      render 'new'
    end
  end

  # PUT /admin_email_templates/1
  # PUT /admin_email_templates/1.xml
  def update
    @email_template = EmailTemplate.find(params[:id])

    if @email_template.update_attributes(params[:email_template])
      flash[:notice] = 'EmailTemplate was successfully updated.'
      @email_template.assets.each(&:save)
      redirect_to :action => 'index', :account_id => current_account, :program_id => current_program
    else
      (15 - @email_template.assets.count).times { @email_template.assets.build }
      render 'edit'
    end
  end

  # DELETE /admin_email_templates/1
  # DELETE /admin_email_templates/1.xml
  def destroy
    @email_template = EmailTemplate.find(params[:id])
    @email_template.destroy

    redirect_to :action => 'index', :account_id => current_account, :program_id => current_program
  end
end
