# Real_Time_Messaging — Quick Ubuntu Setup (Exact Commands)

IMPORTANT: before running tests or starting the server you MUST import the CSV and run the urgency re-score so the database contains the messages the app and tests expect:

Layout required
- Create a top-level folder named `Real_Time_Messaging` containing:
  - `Rails_App/` — the Rails app (this repo)
  - `GeneralistRails_Project_MessageData.csv` — sample CSV

Example:
```
/path/to/Real_Time_Messaging
  ├─ Rails_App/
  └─ GeneralistRails_Project_MessageData.csv
```

Exact macOS and Ubuntu (or WSL) copy‑paste setup — run from a fresh machine

macOS (Homebrew) — copy/paste
```bash
# Install Homebrew if missing
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
```bash
# Install developer tools and runtime dependencies
brew install rbenv ruby-build node yarn postgresql
```
```bash
# Start Postgres
brew services start postgresql
```
```bash
# Install Ruby via rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
source ~/.zshrc
```
```bash
rbenv install 3.3.10
```
```bash
rbenv local 3.3.10
```
```bash
gem install bundler
```
```bash
# Project setup (from Real_Time_Messaging/Rails_App)
cd /path/to/Real_Time_Messaging/Rails_App
bundle install
yarn install
bin/rails db:create db:migrate db:seed
```
```bash
# Import CSV and compute urgency (required BEFORE tests/server)
bin/rails import:messages
bin/rails messages:flag_urgent
```
```bash
# Run tests
bin/rails test
```
```bash
# For development with JS watcher:
bin/dev
```
Open http://localhost:3000/messages

Exact Ubuntu (or WSL) copy‑paste setup — run from a fresh machine

1) Clone repo
```bash
git clone <repo-url> /path/to/Real_Time_Messaging/Rails_App
# replace <repo-url> with the repository HTTPS or SSH URL
```
(Places the Rails project in `/path/to/Real_Time_Messaging/Rails_App`.)

2) Install build tools and common libs
```bash
sudo apt update
sudo apt install -y \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  libffi-dev \
  libyaml-dev \
  libgdbm-dev \
  libncurses5-dev \
  libdb-dev \
  autoconf \
  bison \
  curl \
  git \
  sqlite3 \
  libsqlite3-dev
```
(These provide compilers and headers needed to build Ruby and native gems.)

3) Install rbenv and Ruby
```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

rbenv install 3.3.10
rbenv local 3.3.10
```
```bash
sudo gem install bundler
```
(Installs Ruby 3.3.10 locally via rbenv and bundler to manage gems.)

4) Install Node and Yarn
```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g yarn
```
(Node is required to build frontend JS assets; Yarn installs JS deps.)

5) Install project Ruby and JS dependencies
```bash
cd /path/to/Real_Time_Messaging/Rails_App
bundle install
yarn install
```
(Installs gems from `Gemfile` and JS packages from `package.json`.)

6) Prepare database schemas & seeds (before starting server)
```bash
bin/rails db:create db:migrate db:seed
```
(Creates DB and runs migrations and seeds for initial data.)

7) Install & start PostgreSQL (if you prefer postgres)
```bash
sudo apt update
sudo apt install -y postgresql postgresql-contrib libpq-dev
sudo service postgresql start
sudo -u postgres createuser --superuser $(whoami) || true
sudo -u postgres createdb -O $(whoami) messaging_app_development || true
```
(Ensure Postgres server and client libs are installed. The createuser/createdb lines create a DB role and DB that Rails can use locally. On many Homebrew or packaged installs this step may be unnecessary.)

Ensure GeneralistRails_Project_MessageData.csv is at /path/to/Real_Time_Messaging/GeneralistRails_Project_MessageData.csv

8) Import sample CSV into the app (REQUIRED before tests/server)
```bash
cd /path/to/Real_Time_Messaging/Rails_App
bin/rails import:messages
```
(The import task expects the CSV one level above the Rails app — i.e. in `Real_Time_Messaging`.)

9) Re-score persisted messages (compute & persist urgency) (REQUIRED)
```bash
cd /path/to/Real_Time_Messaging/Rails_App
bin/rails messages:flag_urgent
```

10) Import CSV & re-score (explicit workflow)
```bash
cd /path/to/Real_Time_Messaging/Rails_App
bin/rails import:messages
bin/rails messages:flag_urgent
```

11) Run tests
```bash
cd /path/to/Real_Time_Messaging/Rails_App
bin/rails test
```

12) Start the development server (use `bin/dev` if available for JS watchers)
```bash
cd /path/to/Real_Time_Messaging/Rails_App
bin/dev
```

Then open http://localhost:3000/messages

Short explanations (why these steps)
- System build deps (step 2) let you compile Ruby and native gems.
- rbenv + ruby-build (step 3) install the exact Ruby version used by the project.
- Node & Yarn (step 4) compile frontend assets (app/javascript). Without Node, assets won't build.
- db:create/db:migrate/db:seed (step 6) creates tables and initial data the app expects.
- Postgres (step 7) is the recommended DB; the createuser/createdb commands are for local auth convenience on Ubuntu/WSL.
- Import + flag tasks (steps 8–9) load CSV messages and compute urgency so UI and tests reflect real data.
- `bin/dev` runs servers/watchers (JS + Rails) for development; `bin/rails server` only runs Rails.

---
- What this project is
  - This is a simple messaging web application built with Ruby on Rails. It stores incoming customer messages, computes a short urgency score for each message, and surfaces high-urgency messages in the UI. The app also supports realtime updates so new or re-scored messages are pushed to open browsers.

- Why Ruby on Rails
  - Ruby is the programming language used for app logic.
  - Rails is a web framework that provides structure (models, controllers, views), database migrations, tasks, testing helpers, and ActionCable for realtime features — all of which speed development while adhering to best practices. Rails also has a robust ecosystem with high-quality gems for features like authorization, uploads, and API clients.

- Where messages are stored
  - Logical store: PostgreSQL `messages` table (model: `Message`).
  - Configured DB name (development): `messaging_app_development` (see `config/database.yml`).
  - The message text is saved in the `message_body` column; urgency is saved in the `urgent` integer column.

- How urgency works (short)
  - `app/models/message.rb` computes urgency before saving via `before_validation :detect_urgency`.
  - It uses a weighted keyword map (URGENCY_KEYWORDS), punctuation/temporal cues, amount detection, and an optional ML hook. The result is an integer 0..3 that the UI and queries use to order messages from least to most critical.

Typical developer workflow (summary)
1. Clone repo and place repository under a top-level `Real_Time_Messaging` folder with `Rails_App/` and `GeneralistRails_Project_MessageData.csv` at that root.
2. Install dependencies (Ruby, rbenv, Node/Yarn, Postgres) — see the OS-specific sections above.
3. From `/path/to/Real_Time_Messaging/Rails_App` run:
   - `bundle install` and `yarn install`
   - `bin/rails db:create db:migrate db:seed`
   - `bin/rails import:messages` (imports CSV into development DB)
   - `bin/rails messages:flag_urgent` (computes and persists urgency)
   - `bin/dev` (or `bin/rails server`) to start app
4. Use the Rails console for inspection and ad-hoc operations:
   - `bin/rails console` then `Message.find_by(id: 101)`, `Message.where(urgent: 3)`, `m = Message.create(...)`, etc.

Quick pointers to crucial files
- `app/models/message.rb` — urgency detection and broadcast callbacks
- `app/controllers/messages_controller.rb` — message creation/ingestion
- `lib/tasks/import.rake` — CSV import
- `lib/tasks/messages.rake` — re-score (messages:flag_urgent)
- `app/views/messages/_message.html.erb` — partial used for broadcasts
- `app/javascript/channels/*` — ActionCable client subscriptions and DOM update logic
- `config/database.yml` & `db/schema.rb` — DB connection and table schema