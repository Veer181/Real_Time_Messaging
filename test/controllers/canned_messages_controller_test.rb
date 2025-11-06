require "test_helper"

class CannedMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get canned_messages_url
    assert_response :success
  end

  test "should get new" do
    get new_canned_message_url
    assert_response :success
  end

  test "should create canned_message" do
    assert_difference("CannedMessage.count") do
      post canned_messages_url, params: { canned_message: { title: "Test", body: "Body" } }
    end

    assert_redirected_to canned_message_url(CannedMessage.last)
  end

  test "should get edit" do
    cm = canned_messages(:one)
    get edit_canned_message_url(cm)
    assert_response :success
  end

  test "should update canned_message" do
    cm = canned_messages(:one)
    patch canned_message_url(cm), params: { canned_message: { title: "Updated" } }
    assert_redirected_to canned_message_url(cm)
    cm.reload
    assert_equal "Updated", cm.title
  end

  test "should destroy canned_message" do
    cm = canned_messages(:one)
    assert_difference("CannedMessage.count", -1) do
      delete canned_message_url(cm)
    end

    assert_redirected_to canned_messages_url
  end
end
