require 'test_helper'

class UserCategoriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_category" do
    assert_difference('UserCategory.count') do
      post :create, :user_category => { }
    end

    assert_redirected_to user_category_path(assigns(:user_category))
  end

  test "should show user_category" do
    get :show, :id => user_categories(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => user_categories(:one).id
    assert_response :success
  end

  test "should update user_category" do
    put :update, :id => user_categories(:one).id, :user_category => { }
    assert_redirected_to user_category_path(assigns(:user_category))
  end

  test "should destroy user_category" do
    assert_difference('UserCategory.count', -1) do
      delete :destroy, :id => user_categories(:one).id
    end

    assert_redirected_to user_categories_path
  end
end
