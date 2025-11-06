# Branch Messaging Web Application

This is a robust, scalable messaging web application built with Ruby on Rails. It's designed to handle high-volume customer service inquiries, allowing multiple agents to respond to customer messages efficiently.

## Features

*   **Real-time Messaging:** New messages appear in the UI instantly without needing a page refresh, powered by Action Cable.
*   **Agent-Focused UI:** A clean, modern interface built with Bootstrap that allows agents to view all messages, see message details, and respond.
*   **Intelligent Urgency Scoring:** Messages are automatically assigned an urgency score (High, Medium, Low) based on keywords. The UI uses a color-coded system to help agents prioritize.
*   **Search & Filtering:** Agents can search messages by keyword or customer ID, and filter messages by customer type (New, Returning, VIP).
*   **Customer Information:** When viewing a message, agents can see a dedicated panel with additional customer details, including their name, email, phone number, and type, providing valuable context for every interaction.
*   **Canned Responses:** Agents can use pre-written responses to answer common questions quickly and consistently.
*   **Idempotent Data Import:** A rake task is provided to import an initial dataset from a CSV file, which can be run multiple times without creating duplicate entries.

## Prerequisites: Setting Up Your Development Environment

Before you can run the application, you need to set up your machine with the necessary tools. Please follow the instructions for your operating system.

<details>
<summary><strong>macOS Setup Instructions</strong></summary>

### 1. Install Homebrew

Homebrew is a package manager for macOS that simplifies installing software. If you don't have it, open your terminal and run:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Git

The project is managed with Git. Install it with Homebrew:

```sh
brew install git
```

### 3. Install Ruby

This project uses Ruby. We recommend using a version manager like `rbenv` to avoid conflicts with the system Ruby.

a. **Install rbenv:**

```sh
brew install rbenv ruby-build
```

b. **Set up rbenv in your shell:**

```sh
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.zshrc
source ~/.zshrc
```

c. **Install the correct Ruby version:**

```sh
rbenv install 3.3.0
rbenv global 3.3.0
```

d. **Install the Bundler gem:**

```sh
gem install bundler
```

### 4. Install Node.js and Yarn

The application uses Node.js and Yarn to manage JavaScript packages.

a. **Install Node.js:**

```sh
brew install node
```

b. **Install Yarn:**

```sh
brew install yarn
```

### 5. Install and Start PostgreSQL

The application database runs on PostgreSQL.

a. **Install PostgreSQL:**

```sh
brew install postgresql
```

b. **Start the PostgreSQL service:**

```sh
brew services start postgresql
```
</details>

<details>
<summary><strong>Windows Setup Instructions</strong></summary>

### 1. Install Chocolatey

Chocolatey is a package manager for Windows. If you don't have it, open PowerShell as an **Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```
After installation, close and reopen your PowerShell terminal.

### 2. Install Git, Ruby, Node.js, Yarn, and PostgreSQL

Use Chocolatey to install all the required tools in one command. Open PowerShell as an **Administrator**:

```powershell
choco install git ruby nodejs yarn postgresql -y
```

### 3. Configure Ruby

After the installation, you may need to run the Ruby Installer's `ridk install` to set up the MSYS2 toolchain. Open a new terminal and run:

```powershell
ridk install
```
Select option `3` for MSYS2 and MINGW development toolchain, then press Enter.

### 4. Install Bundler

```powershell
gem install bundler
```

### 5. Setup and Start PostgreSQL

a. **Initialize the Database Cluster (First time only):**
Open PowerShell as an Administrator and run:

```powershell
& "C:\Program Files\PostgreSQL\16\bin\initdb.exe" -D "C:\Program Files\PostgreSQL\16\data"
```
*(Note: Your version number in the path might differ from `16`)*

b. **Start the PostgreSQL service:**
You can start the service from the Services application or by running:

```powershell
net start postgresql-x64-16
```
*(Note: The service name might differ based on your installed version)*
</details>

## Application Setup and Installation

With the prerequisites installed, you can now set up the application.

### 1. Clone the Repository

```sh
# (Replace with your repository URL once you push to GitHub)
git clone <your-repository-url>
cd messaging-app
```

### 2. Install Application Dependencies

This command installs all the Ruby gems and JavaScript packages required by the application.

```sh
bundle install
yarn install
```

### 3. Set Up and Seed the Database

These commands will create the database, apply the schema, and populate it with initial data.

a. **Create and Migrate the Database:**

```sh
bin/rails db:create
bin/rails db:migrate
```

b. **Place the CSV File:**
Before running the import, ensure that the `GeneralistRails_Project_MessageData.csv` file is located in the root directory of the project, one level above the `messaging-app` directory.

c. **Import Initial Messages:**
This task imports the initial set of messages and clients from the provided CSV file.

```sh
bin/rails import:messages
```

d. **Seed Customer Data:**
This task creates customer profiles for the imported clients and assigns them a random customer type (New, Returning, or VIP) to demonstrate the filtering feature.

```sh
bin/rails db:seed
```

e. **Process Message Urgency:**
This task analyzes the imported messages and assigns an urgency score to each one.

```sh
bin/rails messages:flag_urgent
```

## Running the Application

1.  **Start the Development Server**
    The easiest way to run the application is to use the `bin/dev` command, which will automatically build the necessary assets and start the Rails server.
    ```sh
    bin/dev
    ```

2.  **Access the Application**
    Open your web browser and navigate to `http://localhost:3000`.

You should now see the messaging application, populated with the initial data and ready to use.
