require 'test_helper'

class UserLogControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get index_request" do
    get :index_request
    assert_response :success
  end

end
