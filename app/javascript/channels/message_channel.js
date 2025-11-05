import consumer from "channels/consumer"

consumer.subscriptions.create("MessageChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    const messagesContainer = document.querySelector('#messages');
    if (messagesContainer) {
      const messageElement = document.querySelector(`#message_${data.message_id}`);

      if (!messageElement) {
        messagesContainer.insertAdjacentHTML('afterbegin', data.message_html);
      }
    }
  }
});
