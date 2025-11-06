# Lightweight Multinomial Naive Bayes classifier for urgency (pure Ruby).
# Train with labeled Message records (urgent: 0..3) and save model to YAML.
# Usage:
#   clf = UrgentClassifier.new
#   clf.train(messages)                  # messages: ActiveRecord::Relation with message_body & urgent
#   clf.save('tmp/urgent_model.yml')
#   clf2 = UrgentClassifier.load('tmp/urgent_model.yml')
#   clf2.predict("when will my loan be disbursed?")
#
require 'yaml'
class UrgentClassifier
  attr_reader :vocab, :class_counts, :term_counts, :priors, :vocab_size

  def initialize
    @vocab = {}            # token => index
    @class_counts = Hash.new(0)   # label => count
    @term_counts = Hash.new { |h, k| h[k] = Hash.new(0) } # label => { token => count }
    @total_docs = 0
    @vocab_size = 0
  end

  # messages: enumerable of records responding to message_body and urgent
  def train(messages)
    messages.find_each do |m|
      text = m.message_body.to_s.downcase
      label = (m.urgent || 0).to_i
      tokens = tokenize(text)
      next if tokens.empty?

      @class_counts[label] += 1
      @total_docs += 1

      tokens.each do |t|
        index_token(t)
        @term_counts[label][t] += 1
      end
    end

    # compute priors (smoothed)
    @priors = {}
    @class_counts.each do |label, cnt|
      @priors[label] = Math.log((cnt.to_f + 1) / (@total_docs + @class_counts.size))
    end

    @vocab_size = @vocab.size
    self
  end

  # Predict label (0..3) for text. Returns integer label or nil if no info.
  def predict(text)
    return nil if text.to_s.strip.empty?
    return nil if @priors.nil? || @priors.empty?

    tokens = tokenize(text.to_s.downcase)
    return nil if tokens.empty?

    best_label = nil
    best_score = -1.0/0.0 # -Infinity

    @class_counts.keys.each do |label|
      # log-prob start with prior
      score = @priors[label] || Math.log(1e-6)
      total_terms_in_class = @term_counts[label].values.sum + @vocab_size # Laplace denom

      tokens.each do |t|
        term_count = @term_counts[label][t] || 0
        # Laplace smoothing
        prob = (term_count + 1).to_f / total_terms_in_class
        score += Math.log(prob)
      end

      if best_label.nil? || score > best_score
        best_label = label
        best_score = score
      end
    end

    best_label
  end

  # Save model to YAML file
  def save(path)
    data = {
      'vocab' => @vocab,
      'class_counts' => @class_counts,
      'term_counts' => @term_counts,
      'total_docs' => @total_docs
    }
    File.write(path, YAML.dump(data))
  end

  # Load model from YAML file
  def self.load(path)
    raw = YAML.load_file(path)
    clf = new
    clf.instance_variable_set(:@vocab, raw['vocab'] || {})
    clf.instance_variable_set(:@class_counts, (raw['class_counts'] || {}).transform_keys(&:to_i).transform_values(&:to_i))
    # ensure term_counts token keys are strings
    tc = {}
    (raw['term_counts'] || {}).each do |label, hash|
      tc[label.to_i] = (hash || {}).transform_keys(&:to_s).transform_values(&:to_i)
    end
    clf.instance_variable_set(:@term_counts, tc)
    clf.instance_variable_set(:@total_docs, (raw['total_docs'] || 0).to_i)
    clf.instance_variable_set(:@vocab_size, (clf.vocab || {}).size)
    # compute priors
    priors = {}
    clf.class_counts.each do |label, cnt|
      priors[label] = Math.log((cnt.to_f + 1) / (clf.instance_variable_get(:@total_docs) + clf.class_counts.size))
    end
    clf.instance_variable_set(:@priors, priors)
    clf
  end

  private

  def tokenize(text)
    # simple tokenizer: words of length >= 2
    text.scan(/\w{2,}/).map(&:downcase)
  end

  def index_token(token)
    @vocab[token] ||= @vocab.size
  end
end
