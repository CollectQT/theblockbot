require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { date_profile_created: @user.date_profile_created, description: @user.description, display_name: @user.display_name, name: @user.name, site: @user.site, times_blocked: @user.times_blocked, times_reported: @user.times_reported, user_id: @user.user_id }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: { date_profile_created: @user.date_profile_created, description: @user.description, display_name: @user.display_name, name: @user.name, site: @user.site, times_blocked: @user.times_blocked, times_reported: @user.times_reported, user_id: @user.user_id }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
