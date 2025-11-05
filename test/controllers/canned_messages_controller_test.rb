require "test_helper"

class CannedMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get canned_messages_index_url
    assert_response :success
  end

  test "should get new" do
    get canned_messages_new_url
    assert_response :success
  end

  test "should get create" do
    get canned_messages_create_url
    assert_response :success
  end

  test "should get edit" do
    get canned_messages_edit_url
    assert_response :success
  end

  test "should get update" do
    get canned_messages_update_url
    assert_response :success
  end

  test "should get destroy" do
    get canned_messages_destroy_url
    assert_response :success
  end
end
