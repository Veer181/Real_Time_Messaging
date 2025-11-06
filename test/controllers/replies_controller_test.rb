require "test_helper"

class RepliesControllerTest < ActionDispatch::IntegrationTest
  test "should create reply" do
    # create a message to reply to
    message = messages(:one)
    post message_replies_url(message), params: { reply: { body: "OK" } }
    assert_redirected_to message_path(message)
  end
end
