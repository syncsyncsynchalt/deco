class UserManagementController < ApplicationController
  before_filter :authorize, :load_env
  layout 'user_management'
  def index
  end

  def show_moderate
    @moderate = Moderate.find(params[:id])
    render :layout => 'sub'
  end
end
