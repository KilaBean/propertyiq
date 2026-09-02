-- PropertyIQ — Phase 3 migration: profiles + role + RLS
-- Source of truth for the auth identity layer. Run via Supabase SQL editor
-- (or `supabase db push`) before running the Flutter app.

-- 1. Role enum -----------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type public.user_role as enum ('manager', 'tenant');
  end if;
end$$;

-- 2. Shared updated_at trigger function ----------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- 3. profiles table ------------------------------------------------------------
-- id is a 1:1 reference to auth.users. We never store passwords here; Supabase
-- Auth owns credentials. This table holds app-level identity + role.
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text        not null default '',
  role        public.user_role not null default 'tenant',
  phone       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists profiles_role_idx on public.profiles (role);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- 4. Auto-create a profile when a user signs up --------------------------------
-- Pulls full_name / role from the signup metadata (raw_user_meta_data) so the
-- client never has to do a second insert (and can't spoof another user's row).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce((new.raw_user_meta_data ->> 'role')::public.user_role, 'tenant')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 5. Row Level Security --------------------------------------------------------
-- Security boundary lives here, not in the client. For Phase 3 a user may only
-- read and update their OWN profile. (Manager→tenant visibility is added in a
-- later phase once tenancies link the two parties.)
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- No INSERT policy by design: rows are created exclusively by the
-- handle_new_user() trigger (security definer), never by the client.
-- No DELETE policy: profile removal cascades from auth.users deletion only.
