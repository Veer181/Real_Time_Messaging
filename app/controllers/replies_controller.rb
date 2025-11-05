class RepliesController < ApplicationController
  def create
    @message = Message.find(params[:message_id])
    @reply = @message.replies.new(reply_params)

    if @reply.save
      # For now, just redirect back to the message
      redirect_to message_path(@message), notice: 'Reply sent successfully.'
    else
      # Handle failed save
      redirect_to message_path(@message), alert: 'Could not send reply.'
    end
  end

  private

  def reply_params
    params.require(:reply).permit(:body)
  end
end
