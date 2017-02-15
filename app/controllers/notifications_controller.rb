class NotificationsController < ApplicationController
  respond_to :js

  def dismiss
    notification = Notification.find(params[:id])

    notification.dismiss!(current_user)

    render :nothing => true
  end
end
