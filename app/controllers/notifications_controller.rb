class NotificationsController < ApplicationController
  
  def index
    @notifications = current_user.passive_notifications.paginate(page: params[:page])
    @notifications.where(checked: false).each do |notification|
      notification.update_attributes(checked: true)
    end
  end

  def destroy
    @notifications = current_user.passive_notifications.destroy_all
    flash[:notice] = "Deleted all notifications."
    redirect_to notifications_path
  end
end
