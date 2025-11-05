namespace :messages do
  desc "Assign urgency scores to messages based on keywords"
  task flag_urgent: :environment do
    puts "Resetting all message urgency scores to 0..."
    Message.update_all(urgent: 0)

    urgency_levels = {
      high: { score: 3, keywords: ["loan approval", "disbursed", "payment"] },
      medium: { score: 2, keywords: ["urgent", "asap", "emergency", "rejected", "late"] },
      low: { score: 1, keywords: ["update", "info", "how to"] }
    }

    # Process from lowest urgency to highest to ensure higher scores overwrite lower ones
    [:low, :medium, :high].each do |level|
      score = urgency_levels[level][:score]
      keywords = urgency_levels[level][:keywords]
      
      puts "Processing urgency level: #{level} (score: #{score})"
      
      query = keywords.map { |k| "message_body ILIKE '%#{k}%'" }.join(' OR ')
      
      updated_count = Message.where(query).update_all(urgent: score)
      
      puts "-> Flagged #{updated_count} messages."
    end

    puts "\nUrgency flagging complete."
    high_count = Message.where(urgent: 3).count
    medium_count = Message.where(urgent: 2).count
    low_count = Message.where(urgent: 1).count
    puts "Total flagged: #{high_count} high, #{medium_count} medium, #{low_count} low."
  end
end
