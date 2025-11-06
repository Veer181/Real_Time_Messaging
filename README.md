# Messaging App — Urgency Flagging (Developer README)

This README contains concise, industry-standard setup instructions for macOS, Ubuntu/WSL, and Windows (native + WSL). It covers installing dependencies, project bootstrap, running tests and the app, and the admin re-score task. ML training/runtime steps are intentionally omitted.

Prerequisites (common)
- Git
- Ruby (match `.ruby-version`, e.g. 3.3.10)
- Node.js (LTS)
- Yarn or npm
- SQLite3 (default dev/test) or Postgres/MySQL client libs if you change DB
- C toolchain (build-essential / Xcode CLT / MSYS2)

Quick project bootstrap (once repo cloned)
```bash
cd /path/to/BRANCH/messaging-app
bundle install
yarn install
bin/rails db:create db:migrate db:seed
bin/rails test
bin/rails server
# open http://localhost:3000/messages
```

macOS (Homebrew + rbenv) — copy/paste
```bash
# Install system tools
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install rbenv ruby-build node yarn sqlite3

# Install Ruby and set local version
rbenv install 3.3.10
rbenv local 3.3.10
gem install bundler

# Project steps
cd /path/to/BRANCH/messaging-app
bundle install
yarn install
bin/rails db:create db:migrate db:seed
bin/rails test
bin/rails server
```

Ubuntu / WSL (recommended for Windows) — copy/paste
```bash
# Update & toolchain
sudo apt update
sudo apt install -y build-essential curl git libssl-dev libreadline-dev zlib1g-dev sqlite3 libsqlite3-dev

# Install rbenv (or use system manager)
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

rbenv install 3.3.10
rbenv local 3.3.10
gem install bundler

# Node & yarn
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g yarn

# Project steps
cd /path/to/BRANCH/messaging-app
bundle install
yarn install
bin/rails db:create db:migrate db:seed
bin/rails test
bin/rails server
```

Windows native (PowerShell) — copy/paste notes
- Recommended: use WSL2 and follow the Ubuntu/WSL instructions above for best parity.
- If you prefer native Windows:
  1. Install Ruby via RubyInstaller for Windows (choose matching version + MSYS2).
     - https://rubyinstaller.org/ — install DevKit when prompted.
  2. Open a MSYS2/MinGW shell (installed by RubyInstaller) and run:
```powershell
# In PowerShell or MSYS2 shell (adjust paths)
ridk install          # finalize MSYS2 toolchain if using RubyInstaller
gem install bundler
choco install nodejs  # if using Chocolatey (optional)
npm install -g yarn

cd C:\path\to\BRANCH\messaging-app
bundle install
yarn install
bin\rails db:create db:migrate db:seed
bin\rails test
bin\rails server
```
- Note: native Windows may need additional dev headers; WSL2 is simpler for development.

Database notes
- The app's Rails `config/database.yml` is configured for PostgreSQL by default. If you want to use PostgreSQL (recommended for parity with production), install and run a local Postgres server and ensure the `pg` gem is available. Alternatively, you can use sqlite3 locally (no server) by changing `config/database.yml` and the Gemfile.

PostgreSQL (recommended) — quick install & start
- macOS (Homebrew):
```bash
brew install postgresql
brew services start postgresql
# create user/db if needed (adjust names)
createuser -s $(whoami) || true
createdb messaging_app_development || true
```

- Ubuntu / WSL:
```bash
sudo apt update
sudo apt install -y postgresql postgresql-contrib libpq-dev
sudo service postgresql start
# create role and db (run as postgres user)
sudo -u postgres createuser --superuser $(whoami) || true
createdb messaging_app_development || true
```

- Windows:
- Recommended: use the official PostgreSQL installer (https://www.postgresql.org/download/windows/) or run Postgres inside WSL2.
- After installing, ensure the Postgres service is running and create the DB/role as above (or use pgAdmin).

Configure Rails
- `config/database.yml` is set to use PostgreSQL by default. You can either:
  - Create a matching DB/role locally (see above) and run:
    ```bash
    bin/rails db:create db:migrate db:seed
    ```
  - Or provide a connection URL via environment variable:
    ```bash
    export DATABASE_URL="postgres://user:password@localhost/messaging_app_development"
    bin/rails db:create db:migrate db:seed
    ```

sqlite3 (alternative for quick local dev)
- If you prefer sqlite3 (no DB server), update your `Gemfile` to include `gem 'sqlite3'` for the development group and change `config/database.yml` to a sqlite3 config, then run migrations:
```bash
bundle install
bin/rails db:create db:migrate db:seed
```

Troubleshooting DB setups
- If `bin/rails db:create` fails, check the Postgres service is running and the DB user exists.
- If using `pg` gem compile errors occur, install `libpq-dev` (Linux) or ensure `pg_config` is available on PATH (macOS Homebrew postgres provides it).
- Use `DATABASE_URL` to avoid editing `database.yml` when testing alternate setups.

Admin tasks
- Re-score and persist urgency for all messages:
```bash
bin/rails messages:flag_urgent
```

- Import messages from CSV:
  - Place the CSV file named `GeneralistRails_Project_MessageData.csv` one level above the `messaging-app` directory (i.e. `../GeneralistRails_Project_MessageData.csv` when running from `messaging-app`), or update `lib/tasks/import.rake` if you want a different path.
  - Required CSV columns (headers): `User ID`, `Message Body`, `Timestamp (UTC)`
  - Run the import task:
```bash
bin/rails import:messages
```
  - The rake task is idempotent and will create `Client` records as needed and `Message` records using `sent_at` parsed from `Timestamp (UTC)`.

Note: the import task currently expects the file at `Rails.root.join('..', 'GeneralistRails_Project_MessageData.csv')`. If you prefer to keep the CSV elsewhere, edit `lib/tasks/import.rake` to point to a different path or pass a wrapper task that sets the path.
Configuration pointers
- Rule keywords/weights: `app/models/message.rb` → `URGENCY_KEYWORDS`.
- Mapping thresholds: `Message#detect_urgency` in `app/models/message.rb`.
- UI color mappings: `app/helpers/messages_helper.rb`, `app/views/messages/_message.html.erb`.
- ML code present in `lib/urgent_classifier.rb` — operations for training/execution are intentionally not included here.

Files of interest
- app/models/message.rb
- lib/urgent_classifier.rb
- lib/tasks/messages.rake
- app/helpers/messages_helper.rb
- app/views/messages/_message.html.erb
- test/* (model and controller tests)

Troubleshooting
- If tests fail, run `bin/rails test` and inspect failures.
- If `messages:flag_urgent` prints unexpected counts, check the final counts printed by the task and the sample messages shown.
- Ensure Ruby version matches `.ruby-version`. Use rbenv/asdf or your preferred Ruby manager.

Next steps (optional)
- Add admin UI or YAML for tuning keywords/weights.
- Add an automated retraining pipeline and evaluation metrics.
