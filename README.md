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
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=
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

#### Firebase

These let the backend send push notifications through Firebase Cloud Messaging. See [`PUSH_NOTIFICATIONS.md`](PUSH_NOTIFICATIONS.md) for the full push setup (Firebase CLI, `flutterfire configure`, etc.).

1. Sign in to the [Firebase Console](https://console.firebase.google.com) and select (or create) your project.
2. Go to **Project settings → Service accounts** and click **Generate new private key**. A JSON file downloads.
3. Copy these fields from the JSON into `backend/.env`:

   | `.env` variable | JSON field |
   | --- | --- |
   | `FIREBASE_PROJECT_ID` | `project_id` |
   | `FIREBASE_CLIENT_EMAIL` | `client_email` |
   | `FIREBASE_PRIVATE_KEY` | `private_key` |

   ```env
   FIREBASE_PROJECT_ID=...
   FIREBASE_CLIENT_EMAIL=...
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   ```

4. Delete the downloaded JSON file.

> Keep the quotes and the literal `\n`s on the private key; the backend turns them back into newlines. Like the Supabase service key, these credentials are backend-only — never commit them.

### 3. Create the database tables

The schema lives in [`backend/supabase/schema.sql`](backend/supabase/schema.sql).

1. In the Supabase Dashboard, open your project and go to **SQL Editor**.
2. Click **New query**.
3. Paste the full contents of `backend/supabase/schema.sql`.
4. Click **Run**.
5. Check **Table Editor** — you should see `users`, `groups`, `members`, `expenses`, `expense_splits`, `settlements`, `device_tokens` and `user_favorites`.

> The script uses plain `create table`, so running it a second time fails with "relation already exists". To start over, drop the existing tables first.

## Frontend setup

The frontend is a Flutter app in `frontend/`. Make sure the [backend](#backend-setup) is running first.

### 1. Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.13.2`) — run `flutter doctor` to confirm your setup.
- An emulator/simulator or a physical device (`flutter devices` lists what's available).

### 2. Environment variables

Inside `frontend/`, copy `.env.example` to `.env` and fill in the values below:

```bash
cd frontend/
cp .env.example .env
```

```env
CLERK_PUBLISHABLE_KEY=
API_BASE_URL=
```

**`CLERK_PUBLISHABLE_KEY`**

1. In the [Clerk Dashboard](https://dashboard.clerk.com), open the **same application** used by the backend.
2. Go to **Configure → API Keys**.
3. Copy the **Publishable key** (starts with `pk_test_` or `pk_live_`).

**`API_BASE_URL`**

The full GraphQL endpoint of the backend, including `/graphql`. Which host to use depends on where the app runs:

| Running on | `API_BASE_URL` |
| --- | --- |
| iOS simulator, desktop, web | `http://localhost:3000/graphql` |
| Android emulator | `http://10.0.2.2:3000/graphql` (the emulator's alias for your machine's `localhost`) |
| Physical device on the same Wi-Fi | `http://<your-computer-LAN-IP>:3000/graphql` |

> `.env` is bundled as a Flutter asset, so after changing it do a full restart (stop and re-run `flutter run`) — hot reload won't pick it up.

### 3. Install and run

```bash
cd frontend/
flutter pub get
flutter run
```

If more than one device is connected, pick one with `flutter run -d <device-id>`.

Generated files (`*.g.dart`, `*.freezed.dart`) are committed. If you change a Riverpod provider, Freezed model or `json_serializable` class, regenerate them with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Alternative: reach the backend through ngrok

If the app can't reach your local backend (e.g. a physical device on a different network, firewall issues, or you're getting `Network error. Is the backend/ngrok running?`), expose the backend with a public tunnel instead:

1. With the backend running, start a tunnel to its port:

   ```bash
   ngrok http 3000
   ```

2. Copy the **Forwarding** URL ngrok prints (e.g. `https://<random-name>.ngrok-free.app`).
3. Set it in `frontend/.env`, adding `/graphql` at the end:

   ```env
   API_BASE_URL=https://<random-name>.ngrok-free.app/graphql
   ```

4. Fully restart the app (`flutter run`).

The app already sends the `ngrok-skip-browser-warning` header, so ngrok's free-tier warning page won't block requests. Free ngrok URLs change each time you restart ngrok — update `API_BASE_URL` (and the Clerk webhook endpoint, if you set one up with the same tunnel) whenever that happens.
