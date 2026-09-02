-- PropertyIQ — make `units.status` a derived fact instead of a manual toggle.
--
-- Before this migration nothing kept units.status in sync with tenancies: the
-- manager had to flip a segmented control by hand. That let the dashboard
-- contradict itself, because the two occupancy figures read different sources:
--   * dashboardStats  -> units.status         (the "Occupied" KPI)
--   * occupancyTrend  -> tenancy date ranges  (the chart underneath it)
--
-- The rule, stated once and enforced in the database: a unit is `occupied`
-- exactly when it has an ACTIVE tenancy. `tenancies_one_active_per_unit`
-- (0003) already guarantees at most one, so this is well defined.

-- 1. Recompute one unit's status from its tenancies ----------------------------
create or replace function public.refresh_unit_status(p_unit_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_status public.unit_status;
begin
  if p_unit_id is null then
    return;
  end if;

  select case when exists (
           select 1 from public.tenancies t
           where t.unit_id = p_unit_id and t.status = 'active'
         ) then 'occupied' else 'vacant' end::public.unit_status
    into v_status;

  -- `is distinct from` keeps this a no-op when nothing changed, so editing a
  -- tenancy's rent doesn't churn the unit's updated_at.
  update public.units
  set status = v_status
  where id = p_unit_id and status is distinct from v_status;
end;
$$;

-- Trigger-only helper: never call it over the REST API.
revoke execute on function public.refresh_unit_status(uuid)
  from public, anon, authenticated;

-- 2. Fire it on every tenancy change ------------------------------------------
create or replace function public.tenancies_sync_unit_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Branch on TG_OP explicitly. `old`/`new` are only bound for some operations,
  -- and SQL's AND is not guaranteed to short-circuit, so guarding them inside a
  -- single boolean expression could raise "record new is not assigned yet".
  if tg_op = 'INSERT' then
    perform public.refresh_unit_status(new.unit_id);
  elsif tg_op = 'DELETE' then
    perform public.refresh_unit_status(old.unit_id);
  else -- UPDATE: refresh both sides when the tenancy moved between units.
    perform public.refresh_unit_status(old.unit_id);
    if new.unit_id is distinct from old.unit_id then
      perform public.refresh_unit_status(new.unit_id);
    end if;
  end if;
  return null;
end;
$$;

revoke execute on function public.tenancies_sync_unit_status()
  from public, anon, authenticated;

drop trigger if exists tenancies_sync_unit_status on public.tenancies;
create trigger tenancies_sync_unit_status
  after insert or delete or update of status, unit_id on public.tenancies
  for each row execute function public.tenancies_sync_unit_status();

-- 3. Stop the client writing the column directly -------------------------------
-- The manager owns units via `units_via_property_all`, which is a FOR ALL
-- policy and therefore also covers UPDATE. Rather than narrow that policy
-- (and lose label/rent editing), a BEFORE trigger pins `status` to its derived
-- value on any client-side write. The trigger above is the only writer that
-- matters, and it sets the same value this one would compute.
create or replace function public.units_pin_derived_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.status := case when exists (
    select 1 from public.tenancies t
    where t.unit_id = new.id and t.status = 'active'
  ) then 'occupied' else 'vacant' end::public.unit_status;
  return new;
end;
$$;

revoke execute on function public.units_pin_derived_status()
  from public, anon, authenticated;

drop trigger if exists units_pin_derived_status on public.units;
create trigger units_pin_derived_status
  before update of status on public.units
  for each row execute function public.units_pin_derived_status();

-- 4. Backfill existing rows ----------------------------------------------------
-- Runs as the migration owner, so it is not filtered by RLS.
do $$
declare
  v_id uuid;
begin
  for v_id in select id from public.units loop
    perform public.refresh_unit_status(v_id);
  end loop;
end$$;
