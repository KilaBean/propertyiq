-- PropertyIQ — Phase 4 (part 2) migration: tenancies
-- The hub linking a unit to a tenant, with rent terms. Depends on 0001/0002.

-- 1. Enums ---------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'rent_cycle') then
    create type public.rent_cycle as enum ('monthly', 'quarterly', 'yearly');
  end if;
  if not exists (select 1 from pg_type where typname = 'tenancy_status') then
    create type public.tenancy_status as enum ('pending', 'active', 'ended');
  end if;
end$$;

-- 2. tenancies -----------------------------------------------------------------
-- tenant_id is nullable: a manager can invite a tenant by email before that
-- tenant has signed up. tenant_email is the invite target + linkage key.
create table if not exists public.tenancies (
  id           uuid primary key default gen_random_uuid(),
  unit_id      uuid not null references public.units (id) on delete cascade,
  tenant_id    uuid references public.profiles (id) on delete set null,
  tenant_email text not null,
  rent_amount  numeric(12, 2) not null default 0 check (rent_amount >= 0),
  rent_cycle   public.rent_cycle not null default 'monthly',
  start_date   date not null default current_date,
  end_date     date,
  status       public.tenancy_status not null default 'active',
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists tenancies_unit_id_idx on public.tenancies (unit_id);
create index if not exists tenancies_tenant_id_idx on public.tenancies (tenant_id);
create index if not exists tenancies_tenant_email_idx
  on public.tenancies (lower(tenant_email));

-- Business rule as a DB constraint: at most one ACTIVE tenancy per unit.
create unique index if not exists tenancies_one_active_per_unit
  on public.tenancies (unit_id) where status = 'active';

drop trigger if exists tenancies_set_updated_at on public.tenancies;
create trigger tenancies_set_updated_at
  before update on public.tenancies
  for each row execute function public.set_updated_at();

-- 3. Helper: does the caller manage the property that owns this unit? ----------
create or replace function public.manages_unit(p_unit_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.units u
    join public.properties p on p.id = u.property_id
    where u.id = p_unit_id and p.manager_id = auth.uid()
  );
$$;

-- 4. RLS -----------------------------------------------------------------------
alter table public.tenancies enable row level security;

-- Manager: full access to tenancies on units they own.
drop policy if exists "tenancies_manager_all" on public.tenancies;
create policy "tenancies_manager_all"
  on public.tenancies for all
  using (public.manages_unit(unit_id))
  with check (public.manages_unit(unit_id));

-- Tenant: read their own tenancies.
drop policy if exists "tenancies_tenant_select" on public.tenancies;
create policy "tenancies_tenant_select"
  on public.tenancies for select
  using (tenant_id = auth.uid());

-- Tenant read access to the unit + property they are tenanted in (so My Unit
-- can show the label / property name). These are additive SELECT policies.
drop policy if exists "units_tenant_select" on public.units;
create policy "units_tenant_select"
  on public.units for select
  using (
    exists (
      select 1 from public.tenancies t
      where t.unit_id = units.id and t.tenant_id = auth.uid()
    )
  );

drop policy if exists "properties_tenant_select" on public.properties;
create policy "properties_tenant_select"
  on public.properties for select
  using (
    exists (
      select 1
      from public.units u
      join public.tenancies t on t.unit_id = u.id
      where u.property_id = properties.id and t.tenant_id = auth.uid()
    )
  );

-- 5. RPC: create a tenancy and link an existing tenant by email ----------------
-- Runs as definer so it can look up auth.users by email (the manager cannot
-- read other users' rows). Authorisation is enforced via manages_unit().
create or replace function public.create_tenancy(
  p_unit_id      uuid,
  p_tenant_email text,
  p_rent_amount  numeric,
  p_rent_cycle   public.rent_cycle,
  p_start_date   date,
  p_end_date     date
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant_id uuid;
  v_id        uuid;
begin
  if not public.manages_unit(p_unit_id) then
    raise exception 'not authorized for this unit';
  end if;

  select id into v_tenant_id
  from auth.users
  where lower(email) = lower(p_tenant_email)
  limit 1;

  insert into public.tenancies (
    unit_id, tenant_id, tenant_email,
    rent_amount, rent_cycle, start_date, end_date
  )
  values (
    p_unit_id, v_tenant_id, p_tenant_email,
    coalesce(p_rent_amount, 0), coalesce(p_rent_cycle, 'monthly'),
    coalesce(p_start_date, current_date), p_end_date
  )
  returning id into v_id;

  return v_id;
end;
$$;

-- 6. Link pending invites when the tenant later signs up -----------------------
create or replace function public.link_tenancies_on_signup()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.tenancies
  set tenant_id = new.id
  where tenant_id is null and lower(tenant_email) = lower(new.email);
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_link on auth.users;
create trigger on_auth_user_created_link
  after insert on auth.users
  for each row execute function public.link_tenancies_on_signup();
