// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"

document.addEventListener('turbo:load', () => {
  const searchField = document.getElementById('search');

  if (searchField) {
    // Store the initial search value to detect when it's cleared
    let initialValue = searchField.value;

    searchField.addEventListener('input', () => {
      // If the field is cleared, redirect to the root path to show all messages
      if (searchField.value === '' && initialValue !== '') {
        window.location.href = '/';
      }
    });

    // Update initialValue on form submission to correctly handle subsequent clears
    searchField.form.addEventListener('submit', () => {
      initialValue = searchField.value;
    });
  }
});

document.addEventListener('turbo:load', () => {
  const conversationThread = document.getElementById('conversation-thread');

  if (conversationThread) {
    const messageId = conversationThread.dataset.messageId;

    const pollForNewReplies = () => {
      const lastReply = conversationThread.querySelector('[data-reply-id]:last-child');
      const lastReplyId = lastReply ? lastReply.dataset.replyId : 0;

      fetch(`/messages/${messageId}/new_replies?last_reply_id=${lastReplyId}`)
        .then(response => response.json())
        .then(newReplies => {
          if (newReplies.length > 0) {
            newReplies.forEach(reply => {
              const replyElement = document.createElement('div');
              replyElement.classList.add('d-flex', 'justify-content-end');
              replyElement.dataset.replyId = reply.id;

              // This is a simplified template. You might want to use a more robust
              // templating approach or match your existing structure perfectly.
              replyElement.innerHTML = `
                <div class="chat-bubble agent">
                  <p class="mb-0">${reply.body}</p>
                  <small class="text-white-50 d-block text-end mt-2">Just now</small>
                </div>
              `;
              conversationThread.appendChild(replyElement);
            });
            // Scroll to the bottom to show the new message
            window.scrollTo(0, document.body.scrollHeight);
          }
        })
        .catch(error => console.error('Polling error:', error));
    };

    // Poll every 3 seconds
    setInterval(pollForNewReplies, 3000);
  }
});
