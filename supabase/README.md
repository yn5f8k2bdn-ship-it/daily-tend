# Supabase Backend

This directory contains the database schema and Edge Functions that power the
daily wellness companion app. The schema, functions, and identifiers are
brand-neutral so the backend can be reused across environments.

```
supabase/
├── migrations/
│   └── 001_init.sql
├── functions/
│   ├── generate_coach_reply/
│   │   ├── index.ts
│   │   └── deno.json
│   └── nightly_summariser/
│       ├── index.ts
│       └── deno.json
└── README.md
```

---

## 1. Applying migrations

### Option A — Supabase CLI (recommended for local/dev)

```bash
# From the project root:
supabase link --project-ref <your-project-ref>
supabase db push
```

`supabase db push` applies every file under `supabase/migrations/` in
alphabetical order. `001_init.sql` is idempotent, so re-running it is safe
during development.

### Option B — Supabase dashboard SQL editor

1. Open your project in the Supabase dashboard.
2. Go to **SQL Editor → New query**.
3. Paste the contents of `supabase/migrations/001_init.sql`.
4. Click **Run**.

### Required dashboard toggles

- **Database → Extensions**: ensure `pgcrypto` and `pg_cron` are enabled
  (the migration also attempts `CREATE EXTENSION`, but Supabase gates the
  actual install at the project level).
- **Authentication → Providers**: enable the auth providers you need
  (email/password, Google, etc.). Because `001_init.sql` adds an
  `AFTER INSERT` trigger on `auth.users`, every sign-up automatically seeds
  a `profiles` row.

---

## 2. Deploying Edge Functions

From the project root:

```bash
supabase functions deploy generate_coach_reply
supabase functions deploy nightly_summariser
```

Each function is a self-contained Deno module. There is no `package.json` and
no `node_modules` — dependencies are pulled from `esm.sh` at deploy time.

### Testing locally with the Supabase CLI

```bash
# Start the local stack (Postgres, Auth, Edge runtime):
supabase start

# Apply migrations to the local DB:
supabase db reset            # wipes + re-applies all migrations

# Serve functions with env vars from a local file:
supabase functions serve --env-file supabase/.env.local
```

Example `supabase/.env.local` (DO NOT commit this file):

```
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4.1-mini
```

Invoke a function locally:

```bash
# Get a user JWT (sign in via the app or the auth API), then:
curl -X POST http://127.0.0.1:54321/functions/v1/generate_coach_reply \
    -H "Authorization: Bearer $USER_JWT" \
    -H "Content-Type: application/json" \
    -d '{"user_message":"I feel stuck today."}'
```

---

## 3. Environment variables

| Name                          | Where it's set                                | Used by                  | Notes |
| ----------------------------- | --------------------------------------------- | ------------------------ | ----- |
| `SUPABASE_URL`                | Injected automatically in Edge Functions      | Both functions           | Don't set manually for deployed functions. |
| `SUPABASE_ANON_KEY`           | Injected automatically in Edge Functions      | `generate_coach_reply`   | Used to create a per-request client bound to the caller's JWT so RLS applies. |
| `SUPABASE_SERVICE_ROLE_KEY`   | Injected automatically in Edge Functions      | `nightly_summariser`     | Bypasses RLS by design. Never expose to clients. |
| `OPENAI_API_KEY`              | `supabase secrets set OPENAI_API_KEY=...`     | `generate_coach_reply`   | Required. |
| `OPENAI_MODEL`                | `supabase secrets set OPENAI_MODEL=...`       | `generate_coach_reply`   | Optional. Defaults to `gpt-4.1-mini`. |

Set secrets for deployed functions:

```bash
supabase secrets set OPENAI_API_KEY=sk-...
supabase secrets set OPENAI_MODEL=gpt-4.1-mini
```

---

## 4. Scheduling the nightly summariser with pg_cron

The nightly summariser is an HTTP Edge Function. Use `pg_cron` together with
Supabase's `pg_net` extension to POST to it on a schedule.

### One-time setup in the SQL editor

```sql
-- Enable pg_net if not already enabled (Dashboard → Extensions).
create extension if not exists pg_net;

-- Store the function URL and service-role key safely. The recommended path is
-- Supabase Vault; here is the basic shape (replace values with your own):
select vault.create_secret(
    '<your-service-role-key>',
    'service_role_key'
);
select vault.create_secret(
    'https://<project-ref>.supabase.co/functions/v1/nightly_summariser',
    'nightly_summariser_url'
);
```

### The cron line itself

Run every day at 02:15 UTC:

```sql
select cron.schedule(
    'nightly_summariser_daily',
    '15 2 * * *',
    $$
    select net.http_post(
        url     := (select decrypted_secret from vault.decrypted_secrets where name = 'nightly_summariser_url'),
        headers := jsonb_build_object(
            'Content-Type',  'application/json',
            'Authorization', 'Bearer ' || (select decrypted_secret from vault.decrypted_secrets where name = 'service_role_key')
        ),
        body    := '{}'::jsonb
    ) as request_id;
    $$
);
```

To unschedule:

```sql
select cron.unschedule('nightly_summariser_daily');
```

If you prefer not to use Vault, you can inline the URL and service-role key in
the cron body — but Vault is strongly recommended in any environment that
isn't strictly personal/local.

---

## 5. Privacy: what gets sent to OpenAI

**What is sent to OpenAI** (by `generate_coach_reply` only):

- `goal` (free text the user explicitly set).
- `coaching_tone` preference (enum).
- `preferred_zone` preference (enum).
- Numeric aggregates from `v_last_7_checkins` and `v_zone_balance_7d`
  (averages and counts — no free-text content).
- `summary_text` from the latest `ai_summaries` row. This is a short,
  deterministic paragraph generated locally by `nightly_summariser`; it
  contains no raw journal content.
- The **current** user turn (the single `user_message` from the request body).

**What is NEVER sent to OpenAI:**

- Raw `reflection_note` text from `check_ins`.
- Previous rows from `coach_messages` (the user-visible chat history is
  re-rendered locally only; it is not included in OpenAI requests).
- Auth identifiers, emails, display names, or Supabase row ids.
- Raw habit names or habit-log content.

`nightly_summariser` does NOT call OpenAI at all. Its template-based
summariser runs entirely on Supabase infrastructure.

---

## 6. Row-Level Security model

Every table has RLS enabled with four policies (select / insert / update /
delete), each requiring `user_id = auth.uid()`.

- The Flutter client always authenticates with the **anon key + user JWT**;
  RLS is enforced on every query.
- `generate_coach_reply` creates a Supabase client bound to the caller's JWT
  so it, too, is subject to RLS (the views `v_last_7_checkins` and
  `v_zone_balance_7d` use `security_invoker = true` so they filter by the
  caller's `auth.uid()`).
- `nightly_summariser` uses the **service-role key** intentionally so it can
  iterate over all users. It MUST NEVER be exposed to client callers; it
  checks for the service-role token itself as a defence-in-depth measure.

---

## 7. Rate limiting (TODO before GA)

`generate_coach_reply` does not currently rate-limit callers. Before GA,
layer on either:

- a Supabase-side token-bucket table (`coach_rate_limits(user_id, hour, count)`),
  incremented transactionally before each OpenAI call, with a hard daily cap;
- or Supabase's built-in API rate-limit rules at the edge; and
- a per-tier quota (free vs premium) once subscriptions are live.
