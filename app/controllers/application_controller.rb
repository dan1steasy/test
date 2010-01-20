# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  
  filter_parameter_logging 'password', 'pin'
  before_filter :check_authentication, :except => [:login_form, :login, :logout]

  def check_authentication
    unless session[:user]
      session[:intended_controller] = controller_name
      session[:intended_action] = action_name
      session[:intended_id] = params[:id]
      flash[:error] = "Please log in."
      redirect_to :controller => "authentication", :action => "login"
    end
  end
      
  # Create new version of the in_place_edit_for helper to utilize our updated_by fields
  def self.in_place_edit_with_update_for(object, attribute, options = {})
    define_method("set_#{object}_#{attribute}") do
      @item = object.to_s.camelize.constantize.find(params[:id])
      @item.update_attribute(attribute, params[:value])
      # If we have an updated_by attribute, update that too
      if @item.respond_to?("updated_by")
        @item.update_attribute('updated_by', session[:user])
      end
      render :text => @item.send(attribute)
    end
  end

end
