class Admin::AccountsController < AdminController
  respond_to :html
  # GET /admin_accounts
  # GET /admin_accounts.xml
  def index
    @accounts = Account.order_by([[:name, :asc]])
    respond_with(@accounts)
  end

  # GET /admin_accounts/1
  # GET /admin_accounts/1.xml
  def show
    @account = Account.find(params[:id])
    respond_with(@account)
  end

  # GET /admin_accounts/new
  # GET /admin_accounts/new.xml
  def new
    @account = Account.new
    respond_with(@account)
  end

  # GET /admin_accounts/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /admin_accounts
  # POST /admin_accounts.xml
  def create
    @account = Account.new(params[:account])
    flash[:notice] = 'Account was successfully created.' if @account.save
    respond_with(:admin, @account)
  end

  # PUT /admin_accounts/1
  # PUT /admin_accounts/1.xml
  def update
    @account = Account.find(params[:id])
    flash[:notice] = 'Account was successfully updated.' if @account.update_attributes(params[:account])
    respond_with(:admin, @account)
  end

  # DELETE /admin_accounts/1
  # DELETE /admin_accounts/1.xml
  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    respond_with(:admin, @account, :location => admin_accounts_path)
  end
end
