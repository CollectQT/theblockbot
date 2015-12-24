require 'test_helper'

class BlockListsControllerTest < ActionController::TestCase
  setup do
    @block_list = block_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:block_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create block_list" do
    assert_difference('BlockList.count') do
      post :create, block_list: { name: @block_list.name }
    end

    assert_redirected_to block_list_path(assigns(:block_list))
  end

  test "should show block_list" do
    get :show, id: @block_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @block_list
    assert_response :success
  end

  test "should update block_list" do
    patch :update, id: @block_list, block_list: { name: @block_list.name }
    assert_redirected_to block_list_path(assigns(:block_list))
  end

  test "should destroy block_list" do
    assert_difference('BlockList.count', -1) do
      delete :destroy, id: @block_list
    end

    assert_redirected_to block_lists_path
  end
end
