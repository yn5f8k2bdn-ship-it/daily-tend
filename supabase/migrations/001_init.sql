-- =============================================================================
-- 001_init.sql
-- -----------------------------------------------------------------------------
-- Initial schema for the daily wellness companion backend.
--
-- Design principles:
--   * Neutral identifiers (no brand names in tables / functions / enums).
--   * One check-in per user per local calendar day (enforced by unique key on
--     user_id + local_date, where local_date is always the user's wall-clock
--     date, not UTC).
--   * Row-Level Security enabled on every table. Users can only see their own
--     rows. Policies compare row.user_id against auth.uid().
--   * Raw user reflection_note text is STORED, but is never sent to any third
--     party from here; Edge Functions that call OpenAI read only from the
--     `ai_summaries` view/table and structured aggregates.
--   * Idempotent: uses IF NOT EXISTS / CREATE OR REPLACE so the migration can
--     be re-run without error during development.
--
-- This migration is organised into sections:
--   1. Extensions
--   2. Enums
--   3. Trigger helper functions
--   4. Tables (+ constraints + indexes + RLS)
--   5. Policies
--   6. Auth trigger (profile auto-creation)
--   7. Views (aggregates for Edge Functions)
-- =============================================================================


-- =============================================================================
-- 1. Extensions
-- -----------------------------------------------------------------------------
-- pgcrypto:  gen_random_uuid()
-- pg_cron:   used to schedule the nightly_summariser Edge Function.
--            NOTE: pg_cron must also be enabled in the Supabase dashboard
--                  (Database > Extensions). CREATE EXTENSION here is safe
--                  but Supabase gates the actual install at the project level.
-- =============================================================================
create extension if not exists "pgcrypto";
create extension if not exists "pg_cron";


-- =============================================================================
-- 2. Enums
-- -----------------------------------------------------------------------------
-- Wrapped in DO blocks so the migration is idempotent (CREATE TYPE has no
-- IF NOT EXISTS form in PostgreSQL).
-- =============================================================================
do $$
begin
    if not exists (select 1 from pg_type where typname = 'zone') then
        create type zone as enum ('self', 'purpose', 'loved_ones');
    end if;

    if not exists (select 1 from pg_type where typname = 'coaching_tone') then
        create type coaching_tone as enum ('calm', 'practical', 'tough_love', 'reflective');
    end if;

    if not exists (select 1 from pg_type where typname = 'day_type') then
        create type day_type as enum ('recovery', 'gentle', 'momentum', 'balanced');
    end if;

    if not exists (select 1 from pg_type where typname = 'subscription_tier') then
        create type subscription_tier as enum ('free', 'premium');
    end if;

    if not exists (select 1 from pg_type where typname = 'plan_source') then
        create type plan_source as enum ('rules', 'ai');
    end if;

    if not exists (select 1 from pg_type where typname = 'message_role') then
        create type message_role as enum ('user', 'coach');
    end if;
end$$;


-- =============================================================================
-- 3. Trigger helper functions
-- -----------------------------------------------------------------------------
-- set_updated_at():        generic updated_at touch trigger.
-- create_profile_on_signup(): runs after a new auth.users row is inserted and
--                          seeds a matching row in public.profiles. Runs as
--                          SECURITY DEFINER because the auth schema is
--                          privileged; function body only inserts into the
--                          public profiles table using NEW.id.
-- =============================================================================
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create or replace function public.create_profile_on_signup()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.profiles (user_id)
    values (new.id)
    on conflict (user_id) do nothing;
    return new;
end;
$$;


-- =============================================================================
-- 4. Tables
-- =============================================================================

-- -----------------------------------------------------------------------------
-- profiles: 1:1 with auth.users. user_id is both PK and FK.
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
    user_id                 uuid primary key references auth.users(id) on delete cascade,
    display_name            text,
    goal                    text,
    coaching_tone           coaching_tone not null default 'calm',
    preferred_zone          zone,
    reminder_time_learned   time,
    reminder_time_user_set  time,
    onboarding_complete     boolean not null default false,
    timezone                text,
    created_at              timestamptz not null default now(),
    updated_at              timestamptz not null default now()
);

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at
    before update on public.profiles
    for each row execute function public.set_updated_at();


-- -----------------------------------------------------------------------------
-- check_ins: one per user per local calendar day. Numeric scores are 1..5.
-- local_date must be derived in the client from the user's timezone so that
-- the "one check-in per day" semantics match what the user experiences.
-- -----------------------------------------------------------------------------
create table if not exists public.check_ins (
    id                  uuid primary key default gen_random_uuid(),
    user_id             uuid not null references auth.users(id) on delete cascade,
    mood                smallint not null constraint check_ins_mood_range    check (mood    between 1 and 5),
    stress              smallint not null constraint check_ins_stress_range  check (stress  between 1 and 5),
    energy              smallint not null constraint check_ins_energy_range  check (energy  between 1 and 5),
    sleep               smallint not null constraint check_ins_sleep_range   check (sleep   between 1 and 5),
    habit_completion    boolean not null default false,
    focus_zone          zone    not null,
    reflection_note     text,
    local_date          date    not null,
    created_at          timestamptz not null default now(),
    constraint check_ins_one_per_day unique (user_id, local_date)
);

create index if not exists idx_check_ins_user_date
    on public.check_ins (user_id, local_date desc);


-- -----------------------------------------------------------------------------
-- daily_plans: the rules-engine or AI-generated plan for a user-local date.
-- -----------------------------------------------------------------------------
create table if not exists public.daily_plans (
    id                  uuid primary key default gen_random_uuid(),
    user_id             uuid not null references auth.users(id) on delete cascade,
    local_date          date not null,
    primary_focus_zone  zone not null,
    day_type            day_type not null,
    action_self         text,
    action_purpose      text,
    action_loved_ones   text,
    recovery_action     text,
    source              plan_source not null default 'rules',
    generated_at        timestamptz not null default now(),
    constraint daily_plans_one_per_day unique (user_id, local_date)
);

create index if not exists idx_daily_plans_user_date
    on public.daily_plans (user_id, local_date desc);


-- -----------------------------------------------------------------------------
-- habits: user-defined recurring behaviours, tagged to a zone.
-- cadence kept as free-form text for V1 ('daily' / 'weekdays' / 'weekly').
-- -----------------------------------------------------------------------------
create table if not exists public.habits (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid not null references auth.users(id) on delete cascade,
    name        text not null,
    zone        zone not null,
    cadence     text not null default 'daily',
    active      boolean not null default true,
    created_at  timestamptz not null default now()
);

create index if not exists idx_habits_user
    on public.habits (user_id, active);


-- -----------------------------------------------------------------------------
-- habit_logs: per-habit per-day completion. user_id is denormalised so RLS
-- policies stay simple (a single auth.uid() comparison, no join needed).
-- -----------------------------------------------------------------------------
create table if not exists public.habit_logs (
    id          uuid primary key default gen_random_uuid(),
    habit_id    uuid not null references public.habits(id) on delete cascade,
    user_id     uuid not null references auth.users(id) on delete cascade,
    local_date  date not null,
    completed   boolean not null default false,
    created_at  timestamptz not null default now(),
    constraint habit_logs_one_per_day unique (habit_id, local_date)
);

create index if not exists idx_habit_logs_user_date
    on public.habit_logs (user_id, local_date desc);


-- -----------------------------------------------------------------------------
-- ai_summaries: scrubbed, aggregated context that IS safe to send to OpenAI.
-- summary_text is a short deterministic paragraph generated by the nightly
-- summariser Edge Function. aggregates holds numeric rollups as JSON.
-- -----------------------------------------------------------------------------
create table if not exists public.ai_summaries (
    id            uuid primary key default gen_random_uuid(),
    user_id       uuid not null references auth.users(id) on delete cascade,
    window_start  date not null,
    window_end    date not null,
    summary_text  text not null,
    aggregates    jsonb not null default '{}'::jsonb,
    created_at    timestamptz not null default now(),
    constraint ai_summaries_unique_window unique (user_id, window_end)
);

create index if not exists idx_ai_summaries_user_created
    on public.ai_summaries (user_id, created_at desc);


-- -----------------------------------------------------------------------------
-- coach_messages: user-visible chat transcript.
--
-- PRIVACY NOTE: This table stores the full chat history shown to the user.
-- The `generate_coach_reply` Edge Function DOES NOT include prior rows from
-- this table in OpenAI requests. Only the *current* user turn plus the
-- structured ai_summaries context is sent upstream. Historical coach_messages
-- rows exist for on-device rendering only.
-- -----------------------------------------------------------------------------
create table if not exists public.coach_messages (
    id          uuid primary key default gen_random_uuid(),
    user_id     uuid not null references auth.users(id) on delete cascade,
    role        message_role not null,
    content     text not null,
    created_at  timestamptz not null default now()
);

create index if not exists idx_coach_messages_user_created
    on public.coach_messages (user_id, created_at desc);


-- -----------------------------------------------------------------------------
-- subscriptions: placeholder for V1.1 Premium. One row per user (unique).
-- -----------------------------------------------------------------------------
create table if not exists public.subscriptions (
    id              uuid primary key default gen_random_uuid(),
    user_id         uuid not null unique references auth.users(id) on delete cascade,
    tier            subscription_tier not null default 'free',
    started_at      timestamptz,
    expires_at      timestamptz,
    platform        text not null default 'none'
        constraint subscriptions_platform_check
        check (platform in ('google_play', 'stripe', 'none')),
    store_receipt   jsonb,
    updated_at      timestamptz not null default now()
);

drop trigger if exists trg_subscriptions_updated_at on public.subscriptions;
create trigger trg_subscriptions_updated_at
    before update on public.subscriptions
    for each row execute function public.set_updated_at();


-- =============================================================================
-- 5. Row-Level Security
-- -----------------------------------------------------------------------------
-- Enable RLS on every table and add four policies per table (select / insert /
-- update / delete). The policy always requires that the row's user_id matches
-- the calling JWT's auth.uid().
--
-- The Supabase service_role key bypasses RLS by design; it must only be used
-- from trusted server contexts (Edge Functions), never shipped to the client.
-- =============================================================================

alter table public.profiles       enable row level security;
alter table public.check_ins      enable row level security;
alter table public.daily_plans    enable row level security;
alter table public.habits         enable row level security;
alter table public.habit_logs     enable row level security;
alter table public.ai_summaries   enable row level security;
alter table public.coach_messages enable row level security;
alter table public.subscriptions  enable row level security;


-- Helper: create the four canonical policies for a given table. Written
-- explicitly per-table for readability and so auditors can grep each name.

-- profiles ---------------------------------------------------------------
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
    for select using (user_id = auth.uid());

drop policy if exists profiles_insert on public.profiles;
create policy profiles_insert on public.profiles
    for insert with check (user_id = auth.uid());

drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles
    for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists profiles_delete on public.profiles;
create policy profiles_delete on public.profiles
    for delete using (user_id = auth.uid());


-- check_ins --------------------------------------------------------------
drop policy if exists check_ins_select on public.check_ins;
create policy check_ins_select on public.check_ins
    for select using (user_id = auth.uid());

drop policy if exists check_ins_insert on public.check_ins;
create policy check_ins_insert on public.check_ins
    for insert with check (user_id = auth.uid());

drop policy if exists check_ins_update on public.check_ins;
create policy check_ins_update on public.check_ins
    for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists check_ins_delete on public.check_ins;
create policy check_ins_delete on public.check_ins
    for delete using (user_id = auth.uid());


-- daily_plans ------------------------------------------------------------
drop policy if exists daily_plans_select on public.daily_plans;
create policy daily_plans_select on public.daily_plans
    for select using (user_id = auth.uid());

drop policy if exists daily_plans_insert on public.daily_plans;
create policy daily_plans_insert on public.daily_plans
    for insert with check (user_id = auth.uid());

drop policy if exists daily_plans_update on public.daily_plans;
create policy daily_plans_update on public.daily_plans
    for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists daily_plans_delete on public.daily_plans;
create policy daily_plans_delete on public.daily_plans
    for delete using (user_id = auth.uid());


-- habits -----------------------------------------------------------------
drop policy if exists habits_select on public.habits;
create policy habits_select on public.habits
    for select using (user_id = auth.uid());

drop policy if exists habits_insert on public.habits;
create policy habits_insert on public.habits
    for insert with check (user_id = auth.uid());

drop policy if exists habits_update on public.habits;
create policy habits_update on public.habits
    for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists habits_delete on public.habits;
create policy habits_delete on public.habits
    for delete using (user_id = auth.uid());


-- habit_logs -------------------------------------------------------------
drop policy if exists habit_logs_select on public.habit_logs;
create policy habit_logs_select on public.habit_logs
    for select using (user_id = auth.uid());

drop policy if exists habit_logs_insert on public.habit_logs;
create policy habit_logs_insert on public.habit_logs
    for insert with check (user_id = auth.uid());

drop policy if exists habit_logs_update on public.habit_logs;
create policy habit_logs_update on public.habit_logs
    for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists habit_logs_delete on public.habit_logs;
create policy habit_logs_delete on public.habit_logs
    for delete using (user_id = auth.uid());


-- ai_summaries -----------------------------------------------------------
drop policy if exists ai_summaries_select on public.ai_summaries;
create policy ai_summaries_select on public.ai_summaries
    for select using (user_id = auth.uid());

drop policy if exists ai_summaries_insert on public.ai_summaries;
create policy ai_summaries_insert on public.ai_summaries
    for insert with check (user_id = auth.uid());

drop policy if exists ai_summaries_update on public.ai_summaries;
create policy ai_summaries_update on public.ai_summaries
    for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists ai_summaries_delete on public.ai_summaries;
create policy ai_summaries_delete on public.ai_summaries
    for delete using (user_id = auth.uid());


-- coach_messages ---------------------------------------------------------
drop policy if exists coach_messages_select on public.coach_messages;
create policy coach_messages_select on public.coach_messages
    for select using (user_id = auth.uid());

drop policy if exists coach_messages_insert on public.coach_messages;
create policy coach_messages_insert on public.coach_messages
    for insert with check (user_id = auth.uid());

drop policy if exists coach_messages_update on public.coach_messages;
create policy coach_messages_update on public.coach_messages
    for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists coach_messages_delete on public.coach_messages;
create policy coach_messages_delete on public.coach_messages
    for delete using (user_id = auth.uid());


-- subscriptions ----------------------------------------------------------
drop policy if exists subscriptions_select on public.subscriptions;
create policy subscriptions_select on public.subscriptions
    for select using (user_id = auth.uid());

drop policy if exists subscriptions_insert on public.subscriptions;
create policy subscriptions_insert on public.subscriptions
    for insert with check (user_id = auth.uid());

drop policy if exists subscriptions_update on public.subscriptions;
create policy subscriptions_update on public.subscriptions
    for update using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists subscriptions_delete on public.subscriptions;
create policy subscriptions_delete on public.subscriptions
    for delete using (user_id = auth.uid());


-- =============================================================================
-- 6. Auth trigger: auto-create a profile row for every new auth.users row.
-- =============================================================================
drop trigger if exists trg_auth_user_create_profile on auth.users;
create trigger trg_auth_user_create_profile
    after insert on auth.users
    for each row execute function public.create_profile_on_signup();


-- =============================================================================
-- 7. Views for Edge Function aggregates
-- -----------------------------------------------------------------------------
-- Views deliberately filter by auth.uid() so they respect RLS when queried
-- via a user JWT (the row-scoped views appear empty to other users).
-- `security_invoker` makes the view run with the caller's privileges, which
-- is what we want for per-user aggregates.
-- =============================================================================

-- v_last_7_checkins: the caller's last 7 check-ins with numeric rollups
-- available as window fields. The Edge Function typically consumes the
-- aggregated form (avg_mood etc.) plus `days_logged`.
create or replace view public.v_last_7_checkins
with (security_invoker = true) as
with recent as (
    select *
    from public.check_ins
    where user_id = auth.uid()
      and local_date >= (current_date - interval '7 days')
    order by local_date desc
    limit 7
)
select
    user_id,
    count(*)::int                                   as days_logged,
    round(avg(mood)::numeric,   2)                  as avg_mood,
    round(avg(stress)::numeric, 2)                  as avg_stress,
    round(avg(energy)::numeric, 2)                  as avg_energy,
    round(avg(sleep)::numeric,  2)                  as avg_sleep,
    sum(case when habit_completion then 1 else 0 end)::int as habit_days,
    min(local_date)                                 as window_start,
    max(local_date)                                 as window_end
from recent
group by user_id;


-- v_zone_balance_7d: count of each focus_zone in the caller's last 7 days.
create or replace view public.v_zone_balance_7d
with (security_invoker = true) as
select
    user_id,
    sum(case when focus_zone = 'self'        then 1 else 0 end)::int as self_days,
    sum(case when focus_zone = 'purpose'     then 1 else 0 end)::int as purpose_days,
    sum(case when focus_zone = 'loved_ones'  then 1 else 0 end)::int as loved_ones_days
from public.check_ins
where user_id = auth.uid()
  and local_date >= (current_date - interval '7 days')
group by user_id;


-- =============================================================================
-- End of migration 001_init.sql
-- =============================================================================
