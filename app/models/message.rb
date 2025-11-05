class Message < ApplicationRecord
  belongs_to :client
  after_create_commit { broadcast_message }

  private

  def broadcast_message
    ActionCable.server.broadcast('message_channel', {
      message_html: ApplicationController.render(
        partial: 'messages/message',
        locals: { message: self }
      ),
      message_id: self.id
    })
  end
end
