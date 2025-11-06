namespace :messages do
  desc "Assign urgency scores to messages using the Message model (runs model detection & callbacks)"
  task flag_urgent: :environment do
    puts "Running model-based urgency detection for all messages (this will run Message#detect_urgency and persist)."

    updated = { total: 0, changed: 0 }
    Message.find_each.with_index do |m, idx|
      begin
        # run the model detection (it's private) and save if urgency changed
        before = m.urgent
        m.send(:detect_urgency)
        if m.changed? || m.urgent != before
          m.save!(validate: false)
          updated[:changed] += 1
        end
        updated[:total] += 1
      rescue => e
        Rails.logger.debug "flag_urgent: error processing message #{m.id}: #{e.message}"
      end
    end

    puts "Processed #{updated[:total]} messages, updated #{updated[:changed]} records."

    counts = Message.group(:urgent).count
    puts "Final urgency counts: #{counts.inspect}"

    puts "\nSample messages by urgency:"
    [3,2,1,0].each do |u|
      puts "\n--- URGENT #{u} ---"
      Message.where(urgent: u).limit(5).pluck(:id, :message_body).each do |id, body|
        puts "#{id}: #{body}"
      end
    end

    puts "\nModel-based urgency flagging complete."
  end
end
