class CannedMessagesController < ApplicationController
  before_action :set_canned_message, only: [:edit, :update, :destroy]

  def index
    @canned_messages = CannedMessage.all
  end

  def new
    @canned_message = CannedMessage.new
  end

    def create
    @canned_message = CannedMessage.new(canned_message_params)
    if @canned_message.save
      redirect_to canned_message_path(@canned_message), notice: 'Canned message was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @canned_message.update(canned_message_params)
      redirect_to canned_message_path(@canned_message), notice: 'Canned message was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @canned_message.destroy
    redirect_to canned_messages_path, notice: 'Canned message was successfully destroyed.'
  end

  private

  def set_canned_message
    @canned_message = CannedMessage.find(params[:id])
  end

  def canned_message_params
    params.require(:canned_message).permit(:title, :body)
  end
end
