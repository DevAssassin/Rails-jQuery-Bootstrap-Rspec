class Admin::NotificationsController < AdminController
  respond_to :html

  def index
    @notifications = Notification.recent_first
    respond_with(:admin, @notifications)
  end

  def show
    @notification = Notification.find(params[:id])
    respond_with(:admin, @notification)
  end

  def new
    @notification = Notification.new
    respond_with(:admin, @notification)
  end

  def edit
    @notification = Notification.find(params[:id])
  end

  def create
    @notification = Notification.new(params[:notification])
    flash[:notice] = 'Notification was successfully created.' if @notification.save
    respond_with(:admin, @notification)
  end

  def update
    @notification = Notification.find(params[:id])
    flash[:notice] = 'Notification was successfully updated.' if @notification.update_attributes(params[:notification])
    respond_with(:admin, @notification)
  end

  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy
    respond_with(:admin, @notification)
  end
end
