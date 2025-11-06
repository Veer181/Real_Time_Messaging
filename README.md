# Branch Messaging Web Application

A Rails-based internal messaging tool for agents to view, search, filter, and reply to customer messages with real-time updates via polling.

## Prerequisites

- **Ruby** (>= 3.3.0): [Install Ruby](https://www.ruby-lang.org/en/documentation/installation/)
- **Rails** (>= 8.1.1): Install via `gem install rails`
- **Node.js** (>= 16): [Install Node.js](https://nodejs.org/)
- **Yarn**: [Install Yarn](https://classic.yarnpkg.com/en/docs/install/)
- **PostgreSQL**: [Install PostgreSQL](https://www.postgresql.org/download/)

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/Veer181/Graph-Drawing.git
   cd Graph-Drawing/messaging-app
   ```

2. **Install dependencies**
   ```bash
   bundle install
   yarn install
   ```

3. **Configure the database**
   - Update `config/database.yml` with your local PostgreSQL credentials if needed.
   - Create and migrate the database:
     ```bash
     bin/rails db:create
     bin/rails db:migrate
     ```

4. **Import sample data**
   - Place `GeneralistRails_Project_MessageData.csv` at the repository root (one level above `messaging-app`).
   - Run:
     ```bash
     bin/rails import:messages
     bin/rails db:seed
     bin/rails messages:flag_urgent
     ```

5. **Run the application**
   ```bash
   bin/dev
   ```
   - Open [http://localhost:3000](http://localhost:3000) in your browser.

## Features

- Real-time inbox updates via polling (AJAX, updates every 5 seconds)
- Search by keyword or customer ID
- Filter by customer type (New, Returning, VIP)
- Urgency highlighting (High/Medium/Low)
- Conversation view with agent replies and canned responses
- Customer detail panel on the message show page

## Real-time Messaging (Websockets)

- The inbox uses Action Cable (websockets) for real-time updates.
- New messages appear instantly in all open inbox tabs.
- No polling required.
- To test: Open the inbox in multiple browser tabs. When a new message is created, it will show up immediately.

### Action Cable Setup

- Action Cable is enabled by default in Rails.
- For production or advanced local setups, you may need Redis:
  - Install Redis: https://redis.io/download
  - Start Redis server: `redis-server`
  - Update `config/cable.yml` if needed.

## Rake Tasks

- Import messages from CSV (idempotent):
  ```bash
  bin/rails import:messages
  ```
  - CSV path: `Rails.root.join("..", "GeneralistRails_Project_MessageData.csv")`

- Assign urgency based on keywords (idempotent):
  ```bash
  bin/rails messages:flag_urgent
  ```

## Troubleshooting

- **PostgreSQL connection**: Update `config/database.yml` if your local credentials differ.
- **CSV import**: Ensure the CSV file is at the repository root (one level above `messaging-app`).
- **Assets not updating**: Run `bin/dev` and hard refresh. If still stale, restart the dev server.
- **Ruby/Rails/Node/Yarn not found**: Install the required versions as listed above.

## Tests

Run all tests:
```bash
bin/rails test
```

## Important Code

- **Polling JS** (`app/javascript/application.js`):
  ```javascript
  function pollMessages() {
    const params = new URLSearchParams(window.location.search);
    fetch(`/messages?${params.toString()}`, {
      headers: { "X-Requested-With": "XMLHttpRequest" }
    })
      .then(response => response.text())
      .then(html => {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, "text/html");
        const newMessages = doc.querySelector("#messages");
        if (newMessages) {
          document.querySelector("#messages").innerHTML = newMessages.innerHTML;
        }
      })
      .catch(() => {});
  }
  setInterval(pollMessages, 5000);
  ```

- **Controller AJAX Response** (`app/controllers/messages_controller.rb`):
  ```ruby
  respond_to do |format|
    format.html
    format.js   { render partial: "messages/message", collection: @messages, as: :message }
  end
  ```

- **Inbox Table** (`app/views/messages/index.html.erb`):
  ```erb
  <tbody id="messages">
    <%= render @messages %>
  </tbody>
  ```

- **Message Row Partial** (`app/views/messages/_message.html.erb`):
  ```erb
  <tr class="message-row <%= message_row_class(message) %>" data-href="<%= message_path(message) %>" role="link" tabindex="0">
    <!-- ... -->
  </tr>
  ```

## UI Interactivity

- New messages appear automatically in the inbox.
- Click any message row to view details and reply.
- Conversation view supports agent replies and canned responses.
