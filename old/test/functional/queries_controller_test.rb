require 'test_helper'

class QueriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:queries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create query" do
    assert_difference('Query.count') do
      post :create, :query => { }
    end

    assert_redirected_to query_path(assigns(:query))
  end

  test "should show query" do
    get :show, :id => queries(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => queries(:one).to_param
    assert_response :success
  end

  test "should update query" do
    put :update, :id => queries(:one).to_param, :query => { }
    assert_redirected_to query_path(assigns(:query))
  end

  test "should destroy query" do
    assert_difference('Query.count', -1) do
      delete :destroy, :id => queries(:one).to_param
    end

    assert_redirected_to queries_path
  end
end
