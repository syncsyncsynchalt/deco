require 'test_helper'

class AppEnvsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:app_envs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create app_env" do
    assert_difference('AppEnv.count') do
      post :create, :app_env => { }
    end

    assert_redirected_to app_env_path(assigns(:app_env))
  end

  test "should show app_env" do
    get :show, :id => app_envs(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => app_envs(:one).id
    assert_response :success
  end

  test "should update app_env" do
    put :update, :id => app_envs(:one).id, :app_env => { }
    assert_redirected_to app_env_path(assigns(:app_env))
  end

  test "should destroy app_env" do
    assert_difference('AppEnv.count', -1) do
      delete :destroy, :id => app_envs(:one).id
    end

    assert_redirected_to app_envs_path
  end
end
