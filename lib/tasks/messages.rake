namespace :messages do
  desc "Flag urgent messages"
  task flag_urgent: :environment do
    keywords = ["loan approval", "disbursed", "rejected", "late", "payment", "urgent"]
    
    Message.where("message_body ILIKE ANY (array[?])", keywords.map { |k| "%#{k}%" }).update_all(urgent: true)
  end
end
