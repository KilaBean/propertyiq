-- PropertyIQ — Phase 4 migration: properties + units
-- The manager-owned inventory spine. Depends on 0001_profiles.sql
-- (uses public.set_updated_at() and the manager role on profiles).

-- 1. Unit status enum ----------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'unit_status') then
    create type public.unit_status as enum ('vacant', 'occupied');
  end if;
end$$;

-- 2. properties ----------------------------------------------------------------
create table if not exists public.properties (
  id          uuid primary key default gen_random_uuid(),
  manager_id  uuid not null references public.profiles (id) on delete cascade,
  name        text not null,
  address     text,
  currency    text not null default 'NGN',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists properties_manager_id_idx
  on public.properties (manager_id);

drop trigger if exists properties_set_updated_at on public.properties;
create trigger properties_set_updated_at
  before update on public.properties
  for each row execute function public.set_updated_at();

-- 3. units ---------------------------------------------------------------------
create table if not exists public.units (
  id          uuid primary key default gen_random_uuid(),
  property_id uuid not null references public.properties (id) on delete cascade,
  label       text not null,
  bedrooms    int  not null default 0 check (bedrooms >= 0),
  base_rent   numeric(12, 2) not null default 0 check (base_rent >= 0),
  status      public.unit_status not null default 'vacant',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists units_property_id_idx on public.units (property_id);

drop trigger if exists units_set_updated_at on public.units;
create trigger units_set_updated_at
  before update on public.units
  for each row execute function public.set_updated_at();

-- 4. RLS -----------------------------------------------------------------------
alter table public.properties enable row level security;
alter table public.units enable row level security;

-- properties: a manager fully owns their own properties.
drop policy if exists "properties_owner_all" on public.properties;
create policy "properties_owner_all"
  on public.properties for all
  using (auth.uid() = manager_id)
  with check (auth.uid() = manager_id);

-- units: access is derived from owning the parent property. Using a helper
-- avoids repeating the subquery and keeps the policy readable.
create or replace function public.owns_property(p_property_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from public.properties p
    where p.id = p_property_id and p.manager_id = auth.uid()
  );
$$;

drop policy if exists "units_via_property_all" on public.units;
create policy "units_via_property_all"
  on public.units for all
  using (public.owns_property(property_id))
  with check (public.owns_property(property_id));
