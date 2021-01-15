class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller? 
  
  private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys:[:name, :username, :email, :password, :password_confirmation])
      devise_parameter_sanitizer.permit(:sign_in, keys:[:email, :password])
      devise_parameter_sanitizer.permit(:account_update, keys:[:name,  :username, :website, :profile, 
                                                               :email, :phone,    :gender])
    end
    
    def after_sign_in_path_for(resource)
      user_path(current_user)
    end 
  
    def after_sign_out_path_for(resource)
      root_path
    end 
end