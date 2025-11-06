class Message < ApplicationRecord
  belongs_to :client
  has_many :replies, dependent: :destroy

  # Enhanced pattern + weighted-keyword urgency scoring.
  # Uses weighted keyword/phrase matches, temporal tokens and punctuation cues.
  # Produces a coarse numeric urgency score: 0 (none) .. 3 (high).
  URGENCY_KEYWORDS = {
    # high-impact phrases
    "loan approval" => 3,
    "disbursed" => 3,
    "disburse" => 3,
    "disbursement" => 3,
    "emergency" => 3,

    # medium-impact
    "payment" => 2,
    "rejected" => 2,
    "late" => 2,
    "urgent" => 2,
    "asap" => 2,
    "when will" => 3,
    "how long" => 2,

    # low-impact / informational
    "update" => 1,
    "info" => 1,
    "how to" => 1,
    "when" => 1,
    "status" => 2,
    "today" => 2,
    "tomorrow" => 2,
    "now" => 2
  }.freeze

  before_validation :detect_urgency
  after_create_commit { broadcast_message }
  after_commit :broadcast_messages_list, on: [:create, :update], if: -> { saved_change_to_urgent? }

  private

  # Compute an urgency "score" by summing weighted matches and mapping to 0..3.
  # Lightweight ML integration: if a trained UrgentClassifier model exists at
  # tmp/urgent_model.yml it will be loaded and its prediction considered.
  def detect_urgency
    text = message_body.to_s.downcase
    cumulative = 0

    # Negation-aware clause splitting to avoid false positives/negatives
    negation_re = /\b(not|n't|no|never|did not|didn't|haven't|hasn't|didnt)\b/i

    URGENCY_KEYWORDS.each do |kw, weight|
      pattern = Regexp.new("\\b#{Regexp.escape(kw)}\\b", Regexp::IGNORECASE)
      next unless text.match?(pattern)

      # find the clause/sentence containing the keyword
      clause = text.split(/(?<=[\.\?\!])/).find { |c| c.match?(pattern) }
      if clause && clause.match?(negation_re)
        # If customer negates the clause, treat specially: many negations like
        # "I have not received disbursement" imply higher urgency, so boost.
        cumulative += weight + 2
      else
        cumulative += weight
      end
    end

    # Money/amount detection increases urgency
    if text.match?(/\b(?:ksh|kes|usd|\$|ngn|rs)?\s?\d{2,}(?:,\d{3})*(?:\.\d+)?\b/i)
      cumulative += 2
    end

    # Question-mark hint (customers asking "when" or "how long?" are often urgent)
    if text.include?('?')
      if text.match?(/\b(when will|how long|when|disburse|disbursed|status)\b/i)
        cumulative += 2
      else
        cumulative += 1
      end
    end

    # Temporal tokens (today/tomorrow/within/hrs/days/now) suggest immediacy
    cumulative += 2 if text.match?(/\b(today|tomorrow|within|hours|hrs|days|week|now)\b/i)

    # Map cumulative numeric value to discrete urgency levels (0..3)
    rule_based_urgent =
      if cumulative >= 6
        3
      elsif cumulative >= 3
        2
      elsif cumulative >= 1
        1
      else
        0
      end

    # If an ML model is available, load and use it; prefer the higher score between rule-based and ML.
    ml_model_path = Rails.root.join('tmp', 'urgent_model.yml')
    ml_pred = nil
    if defined?(UrgentClassifier) && File.exist?(ml_model_path)
      begin
        clf = UrgentClassifier.load(ml_model_path.to_s)
        ml_pred = clf.predict(text)
        ml_pred = ml_pred.to_i if ml_pred
      rescue => e
        Rails.logger.debug "UrgentClassifier load/predict error: #{e.message}"
      end
    end

    # Choose the stronger signal; ML can override if it predicts higher urgency.
    final_urgent = [rule_based_urgent, (ml_pred || 0)].max

    self.urgent = final_urgent
  end

  # Existing single-message broadcast (kept for backward compatibility)
  def broadcast_message
    ActionCable.server.broadcast('message_channel', {
      message_html: ApplicationController.render(
        partial: 'messages/message',
        locals: { message: self }
      ),
      message_id: self.id
    })
  end

  # Broadcast the full rendered messages list to the MessagesChannel (frontend listens on "messages")
  def broadcast_messages_list
    messages_html = ApplicationController.render(
      partial: 'messages/message',
      collection: Message.all.order(urgent: :desc, created_at: :desc),
      as: :message
    )

    ActionCable.server.broadcast('messages', { message: messages_html })
  end
end
