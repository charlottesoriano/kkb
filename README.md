# kkb

## Backend setup

### 1. Install and run

```bash
cd backend/
npm install
npm run start:dev
```

The server runs on `http://localhost:3000` by default (override with `PORT`).

### 2. Environment variables

Inside `backend/`, copy `.env.example` to `.env` and fill in the values below:

```bash
cp .env.example .env
```

```env
CLERK_SECRET_KEY=
CLERK_WEBHOOK_SIGNING_SECRET=
SUPABASE_URL=
SUPABASE_SERVICE_KEY=
```

#### Clerk

**`CLERK_SECRET_KEY`**

1. Sign in to the [Clerk Dashboard](https://dashboard.clerk.com) and select your application.
2. Go to **Configure → API Keys**.
3. Copy the **Secret key** (starts with `sk_test_` or `sk_live_`).

**`CLERK_WEBHOOK_SIGNING_SECRET`**

Clerk sends user events to `POST /webhooks/clerk`, which keeps the Supabase `users` table in sync. Clerk needs a public URL to reach it, so when running locally expose your server with a tunnel first, e.g.:

```bash
ngrok http 3000
```

1. In the Clerk Dashboard, go to **Configure → Webhooks** and click **Add Endpoint**.
2. Set the **Endpoint URL** to `https://<your-public-url>/webhooks/clerk`.
3. Under **Subscribe to events**, select `user.created`, `user.updated` and `user.deleted`.
4. Click **Create**, then copy the **Signing Secret** (starts with `whsec_`) from the endpoint's page.

#### Supabase

1. Sign in to the [Supabase Dashboard](https://supabase.com/dashboard) and select (or create) your project.
2. **`SUPABASE_URL`** — go to **Project Settings → Data API** and copy the **Project URL** (`https://<project-ref>.supabase.co`).
3. **`SUPABASE_SERVICE_KEY`** — go to **Project Settings → API Keys** and copy the **secret** key (`sb_secret_...`), or the legacy **`service_role`** key.

> The service key bypasses Row Level Security. Keep it on the backend only — never commit it or expose it to the frontend.

### 3. Create the database tables

The schema lives in [`backend/supabase/schema.sql`](backend/supabase/schema.sql).

1. In the Supabase Dashboard, open your project and go to **SQL Editor**.
2. Click **New query**.
3. Paste the full contents of `backend/supabase/schema.sql`.
4. Click **Run**.
5. Check **Table Editor** — you should see `users`, `groups`, `members`, `expenses`, `expense_splits`, `settlements`, `device_tokens` and `user_favorites`.

> The script uses plain `create table`, so running it a second time fails with "relation already exists". To start over, drop the existing tables first.
