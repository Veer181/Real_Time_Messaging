class MessagesController < ApplicationController
  def index
    @messages = if params[:search]
      Message.where("message_body ILIKE ?", "%#{params[:search]}%")
    else
      Message.all
    end.order(urgent: :desc, sent_at: :desc)
  end

  def show
    @message = Message.find(params[:id])
  end

  def new
    @message = Message.new
  end

  def create
    client = Client.find_or_create_by(user_id: params[:message][:client_id])
    @message = Message.new(message_params.merge(client: client))

    if @message.save
      # Broadcast the new message
      ActionCable.server.broadcast(
        "message_channel",
        { message_html: render_to_string(partial: "messages/message", locals: { message: @message }), message_id: @message.id }
      )
      
      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Message was successfully created.' }
        format.js   # We will have a create.js.erb to handle this
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.js   { render :new } # Or handle errors with JS
      end
    end
  end

  def update
    @message = Message.find(params[:id])
    response_body = if params[:message][:canned_message_id].present?
                      CannedMessage.find(params[:message][:canned_message_id]).body
                    else
                      params[:message][:response_body]
                    end

    if response_body.present?
      # For this example, we'll just update the original message body
      # to simulate a response.
      @message.update(message_body: "#{@message.message_body}\n\n--- AGENT RESPONSE ---\n#{response_body}")
      redirect_to message_path(@message), notice: 'Response sent successfully.'
    else
      redirect_to message_path(@message), alert: 'Please select a canned response or write a custom one.'
    end
  end

  private

  def message_params
    params.require(:message).permit(:message_body, :sent_at, :client_id, :response_body, :canned_message_id)
  end
end
