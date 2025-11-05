require 'csv'

namespace :import do
  desc "Import messages from CSV"
  task messages: :environment do
    file_path = Rails.root.join('..', 'GeneralistRails_Project_MessageData.csv')
    
    CSV.foreach(file_path, headers: true) do |row|
      user_id = row['User ID']
      next if user_id.blank?

      client = Client.find_or_create_by!(user_id: user_id)
      sent_at_time = Time.parse(row['Timestamp (UTC)'])

      # Make the import idempotent
      Message.find_or_create_by!(
        client: client,
        message_body: row['Message Body'],
        sent_at: sent_at_time
      )
    end

    puts "Message import complete."
  end
end
