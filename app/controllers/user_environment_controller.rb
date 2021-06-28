class UserEnvironmentController < ApplicationController
  before_action :authorize, :load_env
  layout "user_management"
  def index
  end

  def edit
  end

  def create
    @user = User.find(current_user.id)
    respond_to do |format|
      if @user.update_attributes(users_params(params[:conditions]))
        flash[:notice] = t("user_environment.create..message.ok")
        format.html { redirect_to :action => 'index' }
      else
        flash[:error] = t("user_environment.create..message.ng")
        format.html { render action: "edit" }
      end
    end
  end

  private

  def users_params(post_params)
    post_params.permit(
      :master_frame, :from_organization_add, :to_organization_add
    )
  end
end
