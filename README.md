# Branch Messaging Web Application

This is a robust, scalable messaging web application built with Ruby on Rails. It's designed to handle high-volume customer service inquiries, allowing multiple agents to respond to customer messages efficiently.

## Features

*   **Real-time Messaging:** New messages appear in the UI instantly without needing a page refresh, powered by Action Cable.
*   **Agent-Focused UI:** A clean, modern interface built with Bootstrap that allows agents to view all messages, see message details, and respond.
*   **Urgent Message Flagging:** Messages containing keywords like "urgent" or "asap" are automatically highlighted in yellow to draw agent attention.
*   **Search Functionality:** Agents can search through all messages by keyword.
*   **Canned Responses:** Agents can create, manage, and use pre-written responses to answer common questions quickly and consistently.
*   **Customer Context:** Messages are linked to a customer (client) ID, providing context for interactions.
*   **Idempotent Data Import:** A rake task is provided to import an initial dataset from a CSV file, which can be run multiple times without creating duplicate entries.

## System Requirements

*   Ruby (version 3.3.0 or newer)
*   Rails (version 8.1.1 or newer)
*   PostgreSQL
*   Node.js
*   Yarn

## Setup and Installation

Follow these steps to get the application running on your local machine.

1.  **Clone the Repository**
    ```sh
    # (Replace with your repository URL once you push to GitHub)
    git clone <your-repository-url>
    cd messaging-app
    ```

2.  **Install Dependencies**
    Install the required Ruby gems and JavaScript packages.
    ```sh
    bundle install
    yarn install
    ```

3.  **Set Up the Database**
    This application uses PostgreSQL. Make sure the PostgreSQL service is running.
    ```sh
    # Create the database
    bin/rails db:create

    # Run the database migrations
    bin/rails db:migrate
    ```

4.  **Import Initial Data**
    Populate the database with the initial message data from the provided CSV file.
    ```sh
    # This task is idempotent and can be run safely multiple times.
    bin/rails import:messages
    ```

5.  **Flag Urgent Messages**
    Run the rake task to scan the imported messages and flag the urgent ones.
    ```sh
    bin/rails messages:flag_urgent
    ```

## Running the Application

1.  **Build CSS and JavaScript Assets**
    ```sh
    yarn build
    yarn build:css
    ```

2.  **Start the Rails Server**
    ```sh
    bin/rails server
    ```

3.  **Access the Application**
    Open your web browser and navigate to `http://localhost:3000`.

You should now see the messaging application, populated with the initial data.
