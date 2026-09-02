-- PropertyIQ — Phase 5 migration: maintenance requests
-- Tenant files a request on their unit; AI triage fields are written at insert.
-- Depends on 0001-0003 (profiles, units, manages_unit()).

-- 1. Enums ---------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'maintenance_category') then
    create type public.maintenance_category as enum
      ('plumbing', 'electrical', 'structural', 'hvac', 'appliance', 'pest', 'other');
  end if;
  if not exists (select 1 from pg_type where typname = 'maintenance_priority') then
    create type public.maintenance_priority as enum
      ('low', 'medium', 'high', 'urgent');
  end if;
  if not exists (select 1 from pg_type where typname = 'maintenance_status') then
    create type public.maintenance_status as enum
      ('open', 'in_progress', 'resolved');
  end if;
end$$;

-- 2. maintenance_requests ------------------------------------------------------
create table if not exists public.maintenance_requests (
  id                uuid primary key default gen_random_uuid(),
  unit_id           uuid not null references public.units (id) on delete cascade,
  tenant_id         uuid not null references public.profiles (id) on delete cascade,
  title             text not null,
  description       text,
  category          public.maintenance_category not null default 'other',
  priority          public.maintenance_priority not null default 'medium',
  status            public.maintenance_status not null default 'open',
  ai_recommendation text,
  ai_generated      boolean not null default false,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists maintenance_unit_id_idx
  on public.maintenance_requests (unit_id);
create index if not exists maintenance_tenant_id_idx
  on public.maintenance_requests (tenant_id);
create index if not exists maintenance_status_idx
  on public.maintenance_requests (status);

drop trigger if exists maintenance_set_updated_at on public.maintenance_requests;
create trigger maintenance_set_updated_at
  before update on public.maintenance_requests
  for each row execute function public.set_updated_at();

-- 3. RLS -----------------------------------------------------------------------
alter table public.maintenance_requests enable row level security;

-- Tenant: file a request for themselves, and read their own.
drop policy if exists "maintenance_tenant_insert" on public.maintenance_requests;
create policy "maintenance_tenant_insert"
  on public.maintenance_requests for insert
  with check (tenant_id = auth.uid());

drop policy if exists "maintenance_tenant_select" on public.maintenance_requests;
create policy "maintenance_tenant_select"
  on public.maintenance_requests for select
  using (tenant_id = auth.uid());

-- Manager: full access to requests on units they own (update status etc.).
drop policy if exists "maintenance_manager_all" on public.maintenance_requests;
create policy "maintenance_manager_all"
  on public.maintenance_requests for all
  using (public.manages_unit(unit_id))
  with check (public.manages_unit(unit_id));
