-- PropertyIQ — richer tenant/lease details captured when assigning a tenant.

-- 1. New lease fields on tenancies.
alter table public.tenancies
  add column if not exists utility_amount numeric(12, 2) not null default 0,
  add column if not exists deposit_amount numeric(12, 2) not null default 0,
  add column if not exists emergency_contact text;

-- 2. Store the tenant's phone on their profile at signup (from invite metadata).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role, phone)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce((new.raw_user_meta_data ->> 'role')::public.user_role, 'tenant'),
    nullif(new.raw_user_meta_data ->> 'phone', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

-- 3. create_tenancy now also persists utility / deposit / emergency contact.
drop function if exists public.create_tenancy(
  uuid, text, numeric, public.rent_cycle, date, date);

create or replace function public.create_tenancy(
  p_unit_id           uuid,
  p_tenant_email      text,
  p_rent_amount       numeric,
  p_rent_cycle        public.rent_cycle,
  p_start_date        date,
  p_end_date          date,
  p_utility_amount    numeric,
  p_deposit_amount    numeric,
  p_emergency_contact text
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
    unit_id, tenant_id, tenant_email, rent_amount, rent_cycle,
    start_date, end_date, utility_amount, deposit_amount, emergency_contact
  )
  values (
    p_unit_id, v_tenant_id, p_tenant_email, coalesce(p_rent_amount, 0),
    coalesce(p_rent_cycle, 'monthly'), coalesce(p_start_date, current_date),
    p_end_date, coalesce(p_utility_amount, 0), coalesce(p_deposit_amount, 0),
    p_emergency_contact
  )
  returning id into v_id;

  return v_id;
end;
$$;

revoke execute on function public.create_tenancy(
  uuid, text, numeric, public.rent_cycle, date, date, numeric, numeric, text)
  from public, anon;
grant execute on function public.create_tenancy(
  uuid, text, numeric, public.rent_cycle, date, date, numeric, numeric, text)
  to authenticated;
