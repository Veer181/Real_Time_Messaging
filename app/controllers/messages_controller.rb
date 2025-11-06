class MessagesController < ApplicationController
  def index
    @messages = Message.all.order(urgent: :desc, created_at: :desc)

    if params[:search].present?
      @messages = @messages.joins(client: :customer)
                           .where("messages.message_body ILIKE :search OR CAST(clients.user_id AS TEXT) ILIKE :search", search: "%#{params[:search]}%")
    end

    if params[:customer_type].present?
      type_value = Customer::CUSTOMER_TYPES[params[:customer_type].to_sym]
      if type_value.present?
        @messages = @messages.joins(client: :customer).where(customers: { customer_type: type_value })
      end
    end
  end

  def show
    @message = Message.find(params[:id])
    @customer = Customer.find_or_create_by(user_id: @message.client.user_id)
    @message.update(read_at: Time.current) if @message.read_at.nil?
  end

  def new
    @message = Message.new
  end

  def create
    client = Client.find_or_create_by(user_id: params[:message][:client_id])
    @message = Message.new(message_params.merge(client: client))

    if @message.save
      # Broadcast the new message
      ActionCable.server.broadcast('messages', {
        message: render_to_string(partial: 'messages/message', locals: { message: @message })
      })

      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Message was successfully created.' }
        format.js # Renders create.js.erb
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.js   { render :new, status: :unprocessable_entity }
      end
    end
  end

  def new_replies
    @message = Message.find(params[:id])
    last_reply_id = params[:last_reply_id].to_i
    @new_replies = @message.replies.where("id > ?", last_reply_id).order(created_at: :asc)

    render json: @new_replies
  end

  def update
    @message = Message.find(params[:id])
    response_body = if params[:message][:canned_message_id].present?
                      CannedMessage.find(params[:message][:canned_message_id]).body
                    else
                      params[:message][:response_body]
                    end

    if @message.update(response_body: response_body)
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
