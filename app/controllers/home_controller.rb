class HomeController < ApplicationController
  
  def index
    if user_signed_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page]).search(params[:search])
    end
  end
  
  def help
  end
  
  def about
  end
  
  def contact
  end
  
end
