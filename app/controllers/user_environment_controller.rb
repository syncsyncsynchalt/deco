class UserEnvironmentController < ApplicationController
  before_filter :authorize, :load_env
  layout "user_management"
  def index
  end

  def edit
  end

  def create
    @user = User.find(current_user.id)
    respond_to do |format|
      if @user.update_attributes(params[:conditions])
        flash[:notice] = t("user_environment.create..message.ok")
        format.html { redirect_to :action => 'index' }
      else
        flash[:notice] = t("user_environment.create..message.ng")
        format.html { render action: "edit" }
      end
    end
  end
end
