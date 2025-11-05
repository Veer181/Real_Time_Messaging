class MessagesController < ApplicationController
  def index
    if params[:search].present?
      @messages = Message.where("message_body ILIKE ?", "%#{params[:search]}%").order(urgent: :desc, created_at: :desc)
    else
      @messages = Message.all.order(urgent: :desc, created_at: :desc)
    end
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
