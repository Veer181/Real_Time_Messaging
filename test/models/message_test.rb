require "test_helper"

class MessageTest < ActiveSupport::TestCase
  def setup
    @client = Client.create!(user_id: 9_999_999)
  end

  test "flags high urgency for loan disbursement question" do
    m = Message.create!(client: @client, message_body: "When will my loan be disbursed?", sent_at: Time.current)
    assert_equal 3, m.urgent, "Expected high urgency (3) for disbursement timing question"
  end

    test "flags medium urgency for rejection/payment keywords" do
    m = Message.create!(client: @client, message_body: "My application was rejected, please advise", sent_at: Time.current)
    assert_equal 1, m.urgent, "Expected medium urgency (1) for 'rejected' keyword"
  end

  test "flags low urgency for informational requests" do
    m = Message.create!(client: @client, message_body: "How to update my account info?", sent_at: Time.current)
    assert_equal 2, m.urgent, "Expected low urgency (2) for 'how to' informational request"
  end

  test "negation of receipt increases urgency (boost)" do
    m = Message.create!(client: @client, message_body: "I have not received the disbursement", sent_at: Time.current)
    assert_equal 2, m.urgent, "Expected high urgency (2) when user negates receiving disbursement"
  end

  test "amount mention + immediacy yields medium urgency" do
    m = Message.create!(client: @client, message_body: "I need 5000 now", sent_at: Time.current)
    # rule: amount + 'now' gives cumulative -> mapped to medium (3)
    assert_equal 3, m.urgent, "Expected medium urgency (3) for amount + 'now'"
  end
end
